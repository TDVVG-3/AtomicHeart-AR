using System.IO;
using System.Security.Cryptography;
using System.Text.Json;

namespace AtomicHeartAR;

public sealed record PackageFile(string Name, long Size, string Sha256);
public sealed record InstallManifest(int Schema, string Version, PackageFile[] Files);

public sealed class ModInstaller
{
    public const string Version = "1.0.2";
    public const string ManifestName = "atomic-heart-ar-app-manifest.json";
    public static IReadOnlyList<PackageFile> ReleaseFiles { get; } = Array.AsReadOnly(new[]
    {
        new PackageFile("zzz_atomicheart-ar_carrier_koKR_p12_P.pak", 4470307, "82c2ea5339d09fa440036c507f7aaa258b458c5599a06db77b9cc7de3843fd2f"),
        new PackageFile("zzz_atomicheart-ar_font_p3_unhinted_P.pak", 1455228, "f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4"),
        new PackageFile("zzz_atomicheart-ar_tips_x150_P.pak", 75853, "36de01c37231a8b88ec9fc744c4f663bb8461a56adede9a6a2151d78c7ef7fcc")
    });
    public static IReadOnlyList<PackageFile> PreviousReleaseFiles { get; } = ReleaseFiles.Select(f => f.Name.Contains("carrier_") ? f with { Size = 4470295, Sha256 = "910c06f2609237ac021dc1d3e2a6af02a05c64a828efdfe497a711bac66860c3" } : f).ToArray();
    private readonly IReadOnlyList<PackageFile> files;
    private readonly IReadOnlyList<PackageFile> previousFiles;
    private readonly Action<string>? checkpoint;

    public ModInstaller() : this(ReleaseFiles, previousFiles: PreviousReleaseFiles) { }
    internal ModInstaller(IReadOnlyList<PackageFile> files, Action<string>? checkpoint = null, IReadOnlyList<PackageFile>? previousFiles = null)
    {
        this.files = files;
        this.previousFiles = previousFiles ?? Array.Empty<PackageFile>();
        this.checkpoint = checkpoint;
        foreach (var file in files.Concat(this.previousFiles)) CheckName(file.Name);
    }

    public static string Hash(string path)
    {
        using var stream = File.OpenRead(path);
        return Convert.ToHexString(SHA256.HashData(stream)).ToLowerInvariant();
    }

    private static void CheckName(string name)
    {
        if (string.IsNullOrWhiteSpace(name) || name.IndexOfAny(new[] { '/', '\\', ':' }) >= 0 ||
            Path.GetFileName(name) != name || !name.StartsWith("zzz_atomicheart-ar_", StringComparison.Ordinal) ||
            !name.EndsWith(".pak", StringComparison.Ordinal) || name.Contains(".."))
            throw new InvalidDataException("اسم ملف غير مسموح به في حزمة التعريب.");
    }

    private static void PlainPath(string path)
    {
        var current = Path.GetFullPath(path);
        while (!string.IsNullOrEmpty(current))
        {
            if ((File.Exists(current) || Directory.Exists(current)) &&
                (File.GetAttributes(current) & FileAttributes.ReparsePoint) != 0)
                throw new IOException("المجلد أو أحد ملفاته مرتبط بمسار آخر. اختر المجلد الأصلي مباشرةً.");
            current = Path.GetDirectoryName(current);
        }
    }

    public string ModsPath(string gameRoot)
    {
        if (string.IsNullOrWhiteSpace(gameRoot)) throw new InvalidOperationException("اختر مجلد اللعبة أولًا.");
        var root = Path.GetFullPath(gameRoot);
        PlainPath(root);
        if (!File.Exists(Path.Combine(root, "AtomicHeart.exe")) ||
            !Directory.Exists(Path.Combine(root, "AtomicHeart", "Content", "Paks")))
            throw new DirectoryNotFoundException("اختر مجلد Atomic Heart الذي يحتوي على AtomicHeart.exe.");
        var mods = Path.Combine(root, "AtomicHeart", "Content", "Paks", "~mods");
        PlainPath(mods);
        return mods;
    }

    private static void VerifyFile(string path, PackageFile expected)
    {
        PlainPath(path);
        if (!File.Exists(path)) throw new FileNotFoundException("الملف المطلوب غير موجود: " + expected.Name);
        if (new FileInfo(path).Length != expected.Size || !Hash(path).Equals(expected.Sha256, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("الملف مختلف عن حزمة التعريب المعتمدة: " + expected.Name);
    }

    public void VerifyPackage(string packageRoot)
    {
        if (string.IsNullOrWhiteSpace(packageRoot)) throw new InvalidOperationException("اختر مجلد حزمة التعريب أولًا.");
        PlainPath(packageRoot);
        foreach (var file in files) VerifyFile(Path.Combine(packageRoot, file.Name), file);
    }

    private InstallManifest ReadManifest(string mods)
    {
        var path = Path.Combine(mods, ManifestName);
        PlainPath(path);
        if (new FileInfo(path).Length > 32768) throw new InvalidDataException("سجل تثبيت التعريب غير صالح.");
        InstallManifest? manifest;
        try { manifest = JsonSerializer.Deserialize<InstallManifest>(File.ReadAllText(path)); }
        catch (JsonException ex) { throw new InvalidDataException("تعذّرت قراءة سجل تثبيت التعريب. لم تُعدّل ملفات التعريب.", ex); }
        if (manifest is null || manifest.Schema != 1 || manifest.Files is null || manifest.Files.Length != files.Count)
            throw new InvalidDataException("سجل تثبيت التعريب غير صالح. لم تُعدّل أي ملفات.");
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var item in manifest.Files)
        {
            if (item is null) throw new InvalidDataException("سجل تثبيت التعريب غير صالح.");
            CheckName(item.Name);
            var expected = files.Concat(previousFiles).FirstOrDefault(f => f.Name == item.Name && f.Size == item.Size && f.Sha256.Equals(item.Sha256, StringComparison.OrdinalIgnoreCase));
            if (!seen.Add(item.Name) || expected is null || expected.Size != item.Size ||
                !expected.Sha256.Equals(item.Sha256, StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("سجل التثبيت لا يطابق حزمة التعريب المعتمدة.");
        }
        return manifest;
    }

    public void VerifyInstalled(string gameRoot)
    {
        var mods = ModsPath(gameRoot);
        var manifest = ReadManifest(mods);
        foreach (var file in manifest.Files) VerifyFile(Path.Combine(mods, file.Name), file);
    }

    public bool HasManifest(string gameRoot)
    {
        var mods = ModsPath(gameRoot);
        return File.Exists(Path.Combine(mods, ManifestName));
    }

    public void Install(string gameRoot, string packageRoot, Action<string>? progress = null)
    {
        var mods = ModsPath(gameRoot);
        VerifyPackage(packageRoot);
        if (Path.GetFullPath(packageRoot).Equals(mods, StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("اختر حزمة التعريب من مجلد منفصل عن مجلد التثبيت.");
        if (Directory.Exists(mods) && Directory.EnumerateFiles(mods, "zzz_atomicheart-ar_carrier*.pak").Any(p => !files.Any(f => f.Name == Path.GetFileName(p))))
            throw new InvalidOperationException("يوجد إصدار تعريب آخر في مجلد المودات. أزله بأداته قبل تثبيت هذا الإصدار.");
        Directory.CreateDirectory(mods);
        var lockPath = Path.Combine(mods, ".atomic-heart-ar-app.lock");
        PlainPath(lockPath);
        using var operationLock = new FileStream(lockPath, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.None, 1, FileOptions.DeleteOnClose);
        var manifestPath = Path.Combine(mods, ManifestName);
        PlainPath(manifestPath);
        if (File.Exists(manifestPath)) _ = ReadManifest(mods);
        foreach (var file in files)
        {
            var destination = Path.Combine(mods, file.Name);
            PlainPath(destination);
            if (File.Exists(destination))
            {
                try { VerifyFile(destination, file); }
                catch (InvalidDataException)
                {
                    var previous = previousFiles.FirstOrDefault(p => p.Name == file.Name);
                    if (previous is null) throw;
                    VerifyFile(destination, previous);
                }
            }
        }
        var transaction = Path.Combine(mods, ".atomic-heart-ar-" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(transaction);
        var added = new List<string>();
        var replaced = new List<(string Original, string Saved)>();
        var oldManifest = Path.Combine(transaction, "previous-manifest.json");
        var manifestWritten = false;
        var cleanup = true;
        try
        {
            foreach (var file in files)
            {
                progress?.Invoke("جارٍ تجهيز " + file.Name);
                var staged = Path.Combine(transaction, file.Name);
                File.Copy(Path.Combine(packageRoot, file.Name), staged);
                VerifyFile(staged, file);
            }
            File.WriteAllText(Path.Combine(transaction, "new-manifest.json"), JsonSerializer.Serialize(new InstallManifest(1, Version, files.ToArray()), new JsonSerializerOptions { WriteIndented = true }));
            foreach (var file in files)
            {
                var destination = Path.Combine(mods, file.Name);
                if (File.Exists(destination) && Hash(destination) != file.Sha256)
                {
                    var backup = Path.Combine(transaction, "old-" + file.Name);
                    File.Move(destination, backup);
                    replaced.Add((destination, backup));
                }
                if (!File.Exists(destination))
                {
                    checkpoint?.Invoke("install:" + file.Name);
                    File.Move(Path.Combine(transaction, file.Name), destination);
                    added.Add(destination);
                }
                VerifyFile(destination, file);
            }
            checkpoint?.Invoke("install:manifest");
            if (File.Exists(manifestPath)) File.Move(manifestPath, oldManifest);
            File.Move(Path.Combine(transaction, "new-manifest.json"), manifestPath);
            manifestWritten = true;
            VerifyInstalled(gameRoot);
            progress?.Invoke("تم تثبيت التعريب والتحقق من الملفات الثلاثة.");
        }
        catch (Exception failure)
        {
            try
            {
                if (manifestWritten) File.Delete(manifestPath);
                foreach (var path in added) File.Delete(path);
                foreach (var pair in replaced.AsEnumerable().Reverse()) File.Move(pair.Saved, pair.Original);
                if (File.Exists(oldManifest)) File.Move(oldManifest, manifestPath);
            }
            catch (Exception rollback)
            {
                cleanup = false;
                throw new IOException("تعذّر الاسترجاع التلقائي. احتُفظ بالنسخة في: " + transaction, new AggregateException(failure, rollback));
            }
            throw;
        }
        finally { if (cleanup) Cleanup(transaction); }
    }

    public void Uninstall(string gameRoot, Action<string>? progress = null)
    {
        var mods = ModsPath(gameRoot);
        var lockPath = Path.Combine(mods, ".atomic-heart-ar-app.lock");
        PlainPath(lockPath);
        using var operationLock = new FileStream(lockPath, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.None, 1, FileOptions.DeleteOnClose);
        var installed = ReadManifest(mods);
        // Verify the whole set before moving the first file. A changed file keeps its manifest.
        foreach (var file in installed.Files)
        {
            var path = Path.Combine(mods, file.Name);
            PlainPath(path);
            if (File.Exists(path)) VerifyFile(path, file);
        }
        var transaction = Path.Combine(mods, ".atomic-heart-ar-" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(transaction);
        var moved = new List<(string Original, string Saved)>();
        var cleanup = true;
        try
        {
            foreach (var name in files.Select(f => f.Name).Append(ManifestName))
            {
                var path = Path.Combine(mods, name);
                if (!File.Exists(path)) continue;
                checkpoint?.Invoke("uninstall:" + name);
                var saved = Path.Combine(transaction, name);
                File.Move(path, saved);
                moved.Add((path, saved));
            }
        }
        catch (Exception failure)
        {
            try { foreach (var pair in moved.AsEnumerable().Reverse()) File.Move(pair.Saved, pair.Original); }
            catch (Exception rollback)
            {
                cleanup = false;
                throw new IOException("تعذّر الاسترجاع التلقائي. احتُفظ بالملفات في: " + transaction, new AggregateException(failure, rollback));
            }
            throw;
        }
        finally { if (cleanup) Cleanup(transaction); }
        progress?.Invoke("تمت إزالة ملفات التعريب المسجّلة. موداتك الأخرى بقيت كما هي.");
    }

    private static void Cleanup(string path)
    {
        try { Directory.Delete(path, true); }
        catch (IOException) { /* Keep temporary files if Windows is still holding them. */ }
        catch (UnauthorizedAccessException) { /* A retained transaction directory is safe to remove manually. */ }
    }
}
