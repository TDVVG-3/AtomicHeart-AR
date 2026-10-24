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

            Console.WriteLine("unknown mode " + mode);
            return 2;
        }
    }
}
