using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using UAssetAPI;
using UAssetAPI.UnrealTypes;
using UAssetAPI.ExportTypes;
using UAssetAPI.PropertyTypes.Objects;
using UAssetAPI.PropertyTypes.Structs;

namespace uasettool
{
    internal static class Program
    {
        private static int Main(string[] args)
        {
            Console.OutputEncoding = new UTF8Encoding(false);
            if (args.Length < 2)
            {
                Console.WriteLine("usage: uasettool <info|dump|dtstat|setfloat|setbool|setint> <uasset> [out]");
                Console.WriteLine("       uasettool setfloat <uasset> <property> <value> [out]");
                return 2;
            }

            string mode = args[0];
            string path = args[1];
            EngineVersion version = EngineVersion.VER_UE4_27;
            bool isSetMode = mode == "setfloat" || mode == "setbool" || mode == "setint";
            if (!isSetMode && args.Length > 3 && Enum.TryParse<EngineVersion>(args[3], true, out var v)) version = v;

            var asset = new UAsset(path, version);

            if (mode == "info")
            {
                Console.WriteLine("package: " + asset.FolderName);
                Console.WriteLine("engine: " + asset.GetEngineVersion());
                Console.WriteLine("exports: " + asset.Exports.Count);
                foreach (var e in asset.Exports)
                    Console.WriteLine("  export " + e.GetType().Name + "  " + e.ObjectName);
                return 0;
            }

            if (mode == "dump")
            {
                string outPath = args.Length > 2 ? args[2] : path + ".json";
                var json = asset.SerializeJson();
                File.WriteAllText(outPath, json.ToString(), new UTF8Encoding(false));
                Console.WriteLine("wrote " + outPath);
                return 0;
            }

            if (mode == "probe")
            {
                void DumpType(Type t)
                {
                    Console.WriteLine("TYPE " + t.FullName);
                    foreach (var f in t.GetFields(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static))
                        Console.WriteLine("  FIELD " + f.FieldType.FullName + " " + f.Name);
                    foreach (var p in t.GetProperties(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance))
                        Console.WriteLine("  PROP " + p.PropertyType.FullName + " " + p.Name);
                }
                DumpType(typeof(FStringTable));
                DumpType(typeof(StringTableExport));
                foreach (var e in asset.Exports)
                {
                    Console.WriteLine("EXPORT " + e.ObjectName + " :: " + e.GetType().FullName);
                    if (e is StringTableExport ste)
                    {
                        Console.WriteLine("  Table runtime type: " + (ste.Table == null ? "null" : ste.Table.GetType().FullName));
                        if (ste.Table != null) DumpType(ste.Table.GetType());
                        if (ste.Table != null)
                        {
                            foreach (var kv in ste.Table)
                            {
                                string vs = kv.Value == null ? "" : kv.Value.ToString();
                                Console.WriteLine("  ENTRY " + kv.Key + " LEN " + vs.Length + " B64 " + Convert.ToBase64String(Encoding.UTF8.GetBytes(vs)));
                            }
                        }
                    }
                }
                return 0;
            }

            if (mode == "dtstat")
            {
                var sb = new StringBuilder();
                sb.AppendLine("asset\trow\tmarker\tspeaker\tsentence_key\tru_text\tru_markers\tduration\tpriority");
                foreach (var e in asset.Exports)
                {
                    if (!(e is DataTableExport dte)) continue;
                    foreach (var row in dte.Table.Data)
                    {
                        string marker = ""; string speaker = ""; string skey = ""; string ru = "";
                        string dur = ""; string pr = "";
                        foreach (var p in row.Value)
                        {
                            string pn = p.Name.ToString();
                            if (pn == "Marker" && p is NamePropertyData np) marker = np.Value.ToString();
                            else if (pn == "Speaker" && p is TextPropertyData sp) speaker = sp.CultureInvariantString == null ? "" : sp.CultureInvariantString.ToString();
                            else if (pn == "Sentences" && p is TextPropertyData tp)
                            {
                                skey = tp.Value == null ? "" : tp.Value.ToString();
                                ru = tp.CultureInvariantString == null ? "" : tp.CultureInvariantString.ToString();
                            }
                            else if (pn == "Duration" && p is FloatPropertyData fp) dur = fp.Value.ToString(System.Globalization.CultureInfo.InvariantCulture);
                            else if (pn == "Priority" && p is IntPropertyData ip) pr = ip.Value.ToString();
                        }
                        int marks = 0;
                        foreach (System.Text.RegularExpressions.Match m in System.Text.RegularExpressions.Regex.Matches(ru, "\\*[0-9]+(\\.[0-9]+)?(-[0-9]+(\\.[0-9]+)?)?\\*")) marks++;
                        sb.Append(Path.GetFileName(path)).Append('\t')
                          .Append(row.Name.ToString()).Append('\t')
                          .Append(marker).Append('\t')
                          .Append(speaker.Replace('\t',' ')).Append('\t')
                          .Append(skey).Append('\t')
                          .Append(ru.Replace('\t',' ').Replace('\r',' ').Replace('\n',' ')).Append('\t')
                          .Append(marks).Append('\t')
                          .Append(dur).Append('\t')
                          .Append(pr).AppendLine();
                    }
                }
                string outp = args.Length > 2 ? args[2] : path + ".dtstat.tsv";
                File.WriteAllText(outp, sb.ToString(), new UTF8Encoding(false));
                Console.WriteLine("wrote " + outp);
                return 0;
            }
            if (mode == "setfloat" || mode == "setbool" || mode == "setint")
            {
                if (args.Length < 4)
                {
                    Console.WriteLine("usage: uasettool " + mode + " <uasset> <property> <value> [out]");
                    return 2;
                }
                string prop = args[2];
                string rawValue = args[3];
                string outPath = args.Length > 4 ? args[4] : path;
                float fv = 0f; bool bv = false; int iv = 0;
                if (mode == "setfloat") fv = float.Parse(rawValue, CultureInfo.InvariantCulture);
                else if (mode == "setbool") bv = rawValue == "1" || rawValue.Equals("true", StringComparison.OrdinalIgnoreCase);
                else iv = int.Parse(rawValue, CultureInfo.InvariantCulture);

                int count = 0;
                void WalkOne(PropertyData p)
                {
                    if (p == null) return;
                    if (p.Name != null && p.Name.ToString() == prop)
                    {
                        if (mode == "setfloat" && p is FloatPropertyData fp) { fp.Value = fv; count++; }
                        else if (mode == "setbool" && p is BoolPropertyData bp) { bp.Value = bv; count++; }
                        else if (mode == "setint" && p is IntPropertyData ip) { ip.Value = iv; count++; }
                    }
                    if (p is StructPropertyData sp && sp.Value != null) Walk(sp.Value);
                    if (p is ArrayPropertyData ap && ap.Value != null)
                        foreach (var item in ap.Value) WalkOne(item);
                }
                void Walk(List<PropertyData> props)
                {
                    if (props == null) return;
                    foreach (var p in props) WalkOne(p);
                }

                foreach (var e in asset.Exports)
                {
                    if (e is NormalExport ne) Walk(ne.Data);
                    if (e is DataTableExport dte)
                        foreach (var row in dte.Table.Data) Walk(row.Value);
                }

                if (count == 0)
                {
                    Console.Error.WriteLine("property not found: " + prop);
                    return 3;
                }

                asset.Write(outPath);
                Console.WriteLine("set " + count + " value(s) of " + prop + " to " + rawValue + " -> " + outPath);
                return 0;
            }

            if (mode == "settext")
            {
                if (args.Length < 3)
                {
                    Console.WriteLine("usage: uasettool settext <uasset> <map.tsv> [out] [--strict]");
                    return 2;
                }
                string mapPath = args[2];
                bool strict = false;
                string outPath = null;
                for (int i = 3; i < args.Length; i++)
                {
                    if (args[i] == "--strict") strict = true;
                    else outPath = args[i];
                }
                if (outPath == null) outPath = path;

                // map: kind \t field \t oldBase64 \t newBase64
                var map = new Dictionary<string, string>(StringComparer.Ordinal);
                var keyKind = new Dictionary<string, string>(StringComparer.Ordinal);
                foreach (var line in File.ReadAllLines(mapPath, new UTF8Encoding(false)))
                {
                    if (line.Length == 0 || line[0] == '#') continue;
                    var cols = line.Split('\t');
                    if (cols.Length < 4) continue;
                    if (cols[0] == "kind") continue;
                    string kind = cols[0];
                    string field = cols[1];
                    string oldText = Encoding.UTF8.GetString(Convert.FromBase64String(cols[2]));
                    string newText = Encoding.UTF8.GetString(Convert.FromBase64String(cols[3]));
                    string k = kind + "\u0001" + field + "\u0001" + oldText;
                    if (map.ContainsKey(k))
                    {
                        if (map[k] != newText)
                        {
                            Console.Error.WriteLine("conflicting translations for " + kind + "/" + field + " old=" + oldText);
                            return 4;
                        }
                    }
                    else map[k] = newText;
                }

                int changed = 0;
                var hits = new Dictionary<string, int>(StringComparer.Ordinal);
                void ApplyProps(List<PropertyData> props, string kind)
                {
                    if (props == null) return;
                    foreach (var p in props)
                    {
                        if (p == null) continue;
                        string pn = p.Name == null ? "" : p.Name.ToString();
                        if (p is TextPropertyData tp && tp.CultureInvariantString != null)
                        {
                            string old = tp.CultureInvariantString.ToString();
                            foreach (var k in new[] { kind + "\u0001" + pn + "\u0001" + old, kind + "\u0001" + "\u0001" + old })
                            {
                                if (map.TryGetValue(k, out var nv))
                                {
                                    tp.CultureInvariantString = new FString(nv);
                                    changed++; hits[k] = (hits.TryGetValue(k, out var c) ? c : 0) + 1;
                                    break;
                                }
                            }
                        }
                        else if (p is StrPropertyData spd && spd.Value != null)
                        {
                            string old = spd.Value.ToString();
                            foreach (var k in new[] { kind + "\u0001" + pn + "\u0001" + old, kind + "\u0001" + "\u0001" + old })
                            {
                                if (map.TryGetValue(k, out var nv))
                                {
                                    spd.Value = new FString(nv);
                                    changed++; hits[k] = (hits.TryGetValue(k, out var c) ? c : 0) + 1;
                                    break;
                                }
                            }
                        }
                        if (p is StructPropertyData st && st.Value != null) ApplyProps(st.Value, kind);
                        if (p is ArrayPropertyData ap && ap.Value != null)
                            foreach (var item in ap.Value)
                            {
                                if (item is StructPropertyData st2 && st2.Value != null) ApplyProps(st2.Value, kind);
                                else if (item != null) ApplyProps(new List<PropertyData> { item }, kind);
                            }
                    }
                }

                foreach (var e in asset.Exports)
                {
                    if (e is DataTableExport dte)
                    {
                        foreach (var row in dte.Table.Data) ApplyProps(row.Value, "DataTable");
                    }
                    else if (e is StringTableExport ste && ste.Table != null)
                    {
                        var keys = new List<FString>(ste.Table.Keys);
                        foreach (var key in keys)
                        {
                            FString val = ste.Table[key];
                            if (val == null) continue;
                            string old = val.ToString();
                            foreach (var k in new[] { "StringTable\u0001Table\u0001" + old, "StringTable\u0001\u0001" + old })
                            {
                                if (map.TryGetValue(k, out var nv))
                                {
                                    ste.Table[key] = new FString(nv);
                                    changed++; hits[k] = (hits.TryGetValue(k, out var c) ? c : 0) + 1;
                                    break;
                                }
                            }
                        }
                    }
                    else if (e is NormalExport ne)
                    {
                        ApplyProps(ne.Data, "Normal");
                    }
                }

                int missing = 0;
                foreach (var k in map.Keys)
                {
                    if (!hits.ContainsKey(k))
                    {
                        missing++;
                        var parts = k.Split('\u0001');
                        Console.WriteLine("MISSING\t" + parts[0] + "\t" + parts[1] + "\t" + parts[2]);
                    }
                }

                asset.Write(outPath);
                Console.WriteLine("changed=" + changed + " mapRows=" + map.Count + " missing=" + missing + " -> " + outPath);
                if (strict && missing > 0) return 5;
                return 0;
            }

            Console.WriteLine("unknown mode " + mode);
            return 2;
        }
    }
}
