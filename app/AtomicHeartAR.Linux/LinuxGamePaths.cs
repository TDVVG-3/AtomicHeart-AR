using System.Text;
using System.Text.RegularExpressions;

namespace AtomicHeartAR;

public static class LinuxGamePaths
{
    // Resolve only the user-selected root. Internal Paks/mod symlinks are still refused by the installer.
    public static string ResolveRoot(string path)
    {
        if (string.IsNullOrWhiteSpace(path)) throw new InvalidOperationException("اختر مجلد اللعبة أولًا.");
        var full = Path.GetFullPath(path);
        var current = Path.GetPathRoot(full)!;
        foreach (var part in full[current.Length..].Split(Path.DirectorySeparatorChar, StringSplitOptions.RemoveEmptyEntries))
        {
            current = Path.Combine(current, part);
            var info = new DirectoryInfo(current);
            if (info.LinkTarget is not null) current = info.ResolveLinkTarget(true)?.FullName ?? throw new IOException("تعذّر فتح رابط مجلد اللعبة.");
        }
        return current;
    }
    public static string? Detect()
    {
        var home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
        var libraries = new HashSet<string>(StringComparer.Ordinal)
        {
            Path.Combine(home, ".local/share/Steam"), Path.Combine(home, ".steam/steam"),
            Path.Combine(home, ".var/app/com.valvesoftware.Steam/.local/share/Steam")
        };
        foreach (var root in libraries.ToArray())
        {
            try
            {
                var vdf = Path.Combine(root, "steamapps/libraryfolders.vdf");
                if (!File.Exists(vdf)) continue;
                foreach (Match match in Regex.Matches(File.ReadAllText(vdf), "\"path\"\\s+\"([^\"]+)\""))
                    libraries.Add(match.Groups[1].Value.Replace("\\\\", "\\"));
            }
            catch (IOException) { } catch (UnauthorizedAccessException) { }
        }
        foreach (var library in libraries)
        {
            var candidate = Path.Combine(library, "steamapps/common/Atomic Heart");
            try { if (File.Exists(Path.Combine(candidate, "AtomicHeart.exe"))) return ResolveRoot(candidate); }
            catch (IOException) { } catch (UnauthorizedAccessException) { }
        }
        return null;
    }
    public static void RequireClosed()
    {
        if (!OperatingSystem.IsLinux()) return;
        foreach (var directory in Directory.EnumerateDirectories("/proc"))
        {
            if (!int.TryParse(Path.GetFileName(directory), out _)) continue;
            string command;
            try { command = Encoding.UTF8.GetString(File.ReadAllBytes(Path.Combine(directory, "cmdline"))); }
            catch (IOException) { continue; } catch (UnauthorizedAccessException) { continue; }
            if (command.Split('\0').Any(arg => Regex.IsMatch(arg, @"(?:^|[/\\])AtomicHeart(?:-Win64-Shipping)?\.exe$", RegexOptions.IgnoreCase)))
                throw new InvalidOperationException("أغلق لعبة Atomic Heart في Steam / Proton قبل تغيير ملفات التعريب.");
        }
    }
}
