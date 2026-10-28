using System.Security.Cryptography;
using System.Text.Json;
using AtomicHeartAR;

var root = Path.GetFullPath(args.Length > 0 ? args[0] : Path.Combine(AppContext.BaseDirectory, "test-work"));
Directory.CreateDirectory(root);
var passed = 0;
void Check(bool condition, string message) { if (!condition) throw new Exception(message); }
void Throws(Action action) { try { action(); } catch { return; } throw new Exception("Expected a rejected operation."); }
void Test(string name, Action<Fixture> test)
{
    using var f = new Fixture(root);
    test(f);
    Check(File.ReadAllText(Path.Combine(f.Game, "AtomicHeart.exe")) == "game-executable", "Game executable changed.");
    Check(File.ReadAllText(Path.Combine(f.Paks, "stock.pak")) == "stock-archive", "Stock PAK changed.");
    passed++;
    Console.WriteLine("PASS " + name);
}

Test("fresh install verifies all files and preserves unrelated mods", f =>
{
    Directory.CreateDirectory(f.Mods); File.WriteAllText(Path.Combine(f.Mods, "other-mod.pak"), "other");
    f.Installer.Install(f.Game, f.Package); f.Installer.VerifyInstalled(f.Game);
    Check(File.ReadAllText(Path.Combine(f.Mods, "other-mod.pak")) == "other", "Other mod changed.");
});
Test("repeat installation is idempotent", f =>
{
    f.Installer.Install(f.Game, f.Package);
    var before = f.Files.Select(x => ModInstaller.Hash(Path.Combine(f.Mods, x.Name))).ToArray();
    f.Installer.Install(f.Game, f.Package);
    Check(before.SequenceEqual(f.Files.Select(x => ModInstaller.Hash(Path.Combine(f.Mods, x.Name)))), "Repeat changed files.");
});
Test("uninstall preserves other mods and legacy manifest", f =>
{
    f.Installer.Install(f.Game, f.Package);
    File.WriteAllText(Path.Combine(f.Mods, "other.pak"), "other");
    File.WriteAllText(Path.Combine(f.Mods, "atomic-heart-ar-install-manifest.json"), "legacy");
    f.Installer.Uninstall(f.Game);
    Check(f.Files.All(x => !File.Exists(Path.Combine(f.Mods, x.Name))), "Owned file remains.");
    Check(File.Exists(Path.Combine(f.Mods, "other.pak")), "Other mod deleted.");
    Check(File.ReadAllText(Path.Combine(f.Mods, "atomic-heart-ar-install-manifest.json")) == "legacy", "Legacy manifest changed.");
});
Test("changed installed file refuses whole uninstall and retains manifest", f =>
{
    f.Installer.Install(f.Game, f.Package);
    File.WriteAllText(Path.Combine(f.Mods, f.Files[1].Name), "changed");
    Throws(() => f.Installer.Uninstall(f.Game));
    Check(f.Files.All(x => File.Exists(Path.Combine(f.Mods, x.Name))) && File.Exists(f.Manifest), "Partial uninstall.");
});
Test("bad payload does not create mods folder", f =>
{
    File.WriteAllText(Path.Combine(f.Package, f.Files[0].Name), "bad");
    Throws(() => f.Installer.Install(f.Game, f.Package));
    Check(!Directory.Exists(f.Mods), "Bad payload wrote game directory.");
});
Test("unknown same-name destination is not overwritten", f =>
{
    Directory.CreateDirectory(f.Mods); var target = Path.Combine(f.Mods, f.Files[0].Name);
    File.WriteAllText(target, "foreign"); Throws(() => f.Installer.Install(f.Game, f.Package));
    Check(File.ReadAllText(target) == "foreign" && !File.Exists(f.Manifest), "Foreign file overwritten.");
});
Test("path traversal in manifest rejected before deletion", f =>
{
    f.Installer.Install(f.Game, f.Package);
    var items = f.Files.ToArray(); items[0] = items[0] with { Name = "../stock.pak" };
    File.WriteAllText(f.Manifest, JsonSerializer.Serialize(new InstallManifest(1, "1.0.1", items)));
    Throws(() => f.Installer.Uninstall(f.Game));
    Check(f.Files.All(x => File.Exists(Path.Combine(f.Mods, x.Name))), "Traversal removed a file.");
});
Test("unknown manifest names rejected", f =>
{
    f.Installer.Install(f.Game, f.Package);
    var items = f.Files.ToArray(); items[0] = items[0] with { Name = "zzz_atomicheart-ar_unknown.pak" };
    File.WriteAllText(f.Manifest, JsonSerializer.Serialize(new InstallManifest(1, "1.0.1", items)));
    Throws(() => f.Installer.Uninstall(f.Game)); Check(File.Exists(f.Manifest), "Manifest lost.");
});
Test("duplicate manifest entries rejected", f =>
{
    f.Installer.Install(f.Game, f.Package);
    File.WriteAllText(f.Manifest, JsonSerializer.Serialize(new InstallManifest(1, "1.0.1", new[] { f.Files[0], f.Files[0], f.Files[0] })));
    Throws(() => f.Installer.Uninstall(f.Game)); Check(File.Exists(f.Manifest), "Manifest lost.");
});
Test("missing installed file can be repaired", f =>
{
    f.Installer.Install(f.Game, f.Package); File.Delete(Path.Combine(f.Mods, f.Files[0].Name));
    f.Installer.Install(f.Game, f.Package); f.Installer.VerifyInstalled(f.Game);
});
Test("install failure rolls back added files", f =>
{
    var failing = new ModInstaller(f.Files, step => { if (step == "install:" + f.Files[1].Name) throw new IOException("injected"); });
    Throws(() => failing.Install(f.Game, f.Package));
    Check(f.Files.All(x => !File.Exists(Path.Combine(f.Mods, x.Name))) && !File.Exists(f.Manifest), "Install rollback incomplete.");
});
Test("manifest replacement failure restores old manifest", f =>
{
    f.Installer.Install(f.Game, f.Package); var original = File.ReadAllText(f.Manifest);
    var failing = new ModInstaller(f.Files, step =>
    {
        if (step == "install:manifest")
            File.Delete(Path.Combine(Directory.GetDirectories(f.Mods, ".atomic-heart-ar-*").Single(), "new-manifest.json"));
    });
    Throws(() => failing.Install(f.Game, f.Package));
    Check(File.ReadAllText(f.Manifest) == original, "Old manifest not restored."); f.Installer.VerifyInstalled(f.Game);
});
Test("uninstall failure restores moved files", f =>
{
    f.Installer.Install(f.Game, f.Package);
    var failing = new ModInstaller(f.Files, step => { if (step == "uninstall:" + f.Files[1].Name) throw new IOException("injected"); });
    Throws(() => failing.Uninstall(f.Game)); f.Installer.VerifyInstalled(f.Game);
});
Test("failed rollback retains recovery copy", f =>
{
    f.Installer.Install(f.Game, f.Package);
    var failing = new ModInstaller(f.Files, step =>
    {
        if (step != "uninstall:" + f.Files[1].Name) return;
        File.WriteAllText(Path.Combine(f.Mods, f.Files[0].Name), "interference");
        throw new IOException("injected");
    });
    Throws(() => failing.Uninstall(f.Game));
    var recovery = Directory.GetDirectories(f.Mods, ".atomic-heart-ar-*").Single();
    Check(ModInstaller.Hash(Path.Combine(recovery, f.Files[0].Name)) == f.Files[0].Sha256, "Recovery copy lost.");
});
Test("corrupt manifest blocks both mutations", f =>
{
    Directory.CreateDirectory(f.Mods); File.WriteAllText(f.Manifest, "not-json");
    Throws(() => f.Installer.Install(f.Game, f.Package)); Throws(() => f.Installer.Uninstall(f.Game));
    Check(File.ReadAllText(f.Manifest) == "not-json", "Corrupt manifest overwritten.");
});
Test("package cannot be installation destination", f =>
{
    f.Installer.Install(f.Game, f.Package); Throws(() => f.Installer.Install(f.Game, f.Mods));
    f.Installer.VerifyInstalled(f.Game);
});
Test("game root must contain executable and Paks", f =>
{
    Throws(() => f.Installer.ModsPath(f.Package));
    Check(!Directory.Exists(Path.Combine(f.Package, "AtomicHeart")), "Invalid game path changed.");
});
Test("parallel writer is refused", f =>
{
    Directory.CreateDirectory(f.Mods);
    using var held = new FileStream(Path.Combine(f.Mods, ".atomic-heart-ar-app.lock"), FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.None);
    Throws(() => f.Installer.Install(f.Game, f.Package)); Check(!File.Exists(f.Manifest), "Parallel write happened.");
});
Test("unsafe package filename rejected", f =>
{
    Throws(() => new ModInstaller(new[] { f.Files[0] with { Name = "..\\stock.pak" } }));
});
if (args.Length > 1)
{
    using var real = new Fixture(root);
    var production = new ModInstaller();
    production.VerifyPackage(args[1]);
    production.Install(real.Game, args[1]);
    production.VerifyInstalled(real.Game);
    production.Uninstall(real.Game);
    Check(File.ReadAllText(Path.Combine(real.Paks, "stock.pak")) == "stock-archive", "Real package changed stock files.");
    passed++;
    Console.WriteLine("PASS official p12 payload install / verify / uninstall in fake game folder");
}
Console.WriteLine($"{passed} safety checks passed. All fixture operations stayed under {root}");

sealed class Fixture : IDisposable
{
    private readonly string root;
    public string Game { get; }
    public string Paks { get; }
    public string Mods => Path.Combine(Paks, "~mods");
    public string Manifest => Path.Combine(Mods, ModInstaller.ManifestName);
    public string Package { get; }
    public PackageFile[] Files { get; }
    public ModInstaller Installer { get; }
    public Fixture(string parent)
    {
        root = Path.Combine(parent, "fixture-" + Guid.NewGuid().ToString("N"));
        Game = Path.Combine(root, "لعبة Atomic Heart"); Paks = Path.Combine(Game, "AtomicHeart", "Content", "Paks");
        Package = Path.Combine(root, "حزمة التعريب"); Directory.CreateDirectory(Paks); Directory.CreateDirectory(Package);
        File.WriteAllText(Path.Combine(Game, "AtomicHeart.exe"), "game-executable");
        File.WriteAllText(Path.Combine(Paks, "stock.pak"), "stock-archive");
        Files = ModInstaller.ReleaseFiles.Select((file, i) =>
        {
            var bytes = System.Text.Encoding.UTF8.GetBytes("fixture-payload-" + i);
            File.WriteAllBytes(Path.Combine(Package, file.Name), bytes);
            return new PackageFile(file.Name, bytes.Length, Convert.ToHexString(SHA256.HashData(bytes)).ToLowerInvariant());
        }).ToArray();
        Installer = new ModInstaller(Files);
    }
    public void Dispose()
    {
        // Every fixture uses a newly created GUID child, never a caller-supplied deletion target.
        if (!Path.GetFileName(root).StartsWith("fixture-", StringComparison.Ordinal)) throw new Exception("Unsafe fixture cleanup.");
        Directory.Delete(root, true);
    }
}
