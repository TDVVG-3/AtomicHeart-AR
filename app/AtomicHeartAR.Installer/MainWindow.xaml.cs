using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Media;
using Microsoft.Win32;

namespace AtomicHeartAR;

public partial class MainWindow : Window
{
    private readonly ModInstaller installer = new();
    private bool busy;

    public MainWindow()
    {
        InitializeComponent();
        Closing += OnClosing;
        Loaded += (_, _) =>
        {
            GamePathBox.Text = DetectGame() ?? "";
            var bundled = Path.Combine(AppContext.BaseDirectory, "payload");
            if (Directory.Exists(bundled))
            {
                PackagePathBox.Text = bundled;
                PackageHint.Text = "حزمة p12 مرفقة وجاهزة للفحص. اختر مجلد اللعبة للمتابعة.";
            }
            UpdateButtons();
        };
    }

    private void OnClosing(object? sender, CancelEventArgs e)
    {
        if (!busy) return;
        e.Cancel = true;
        Log("انتظر اكتمال العملية أو الاسترجاع قبل إغلاق التطبيق.");
    }

    private void Minimize_Click(object sender, RoutedEventArgs e) => WindowState = WindowState.Minimized;
    private void Maximize_Click(object sender, RoutedEventArgs e) => WindowState = WindowState == WindowState.Maximized ? WindowState.Normal : WindowState.Maximized;
    private void Close_Click(object sender, RoutedEventArgs e) => Close();
    private void Guide_Click(object sender, RoutedEventArgs e) => GuidePanel.Visibility = Visibility.Visible;
    private void CloseGuide_Click(object sender, RoutedEventArgs e) => GuidePanel.Visibility = Visibility.Collapsed;
    private void Project_Click(object sender, RoutedEventArgs e) => OpenPage("https://github.com/TDVVG-3/AtomicHeart-AR");
    private void Releases_Click(object sender, RoutedEventArgs e) => OpenPage("https://github.com/TDVVG-3/AtomicHeart-AR/releases");
    private static void OpenPage(string url) => Process.Start(new ProcessStartInfo(url) { UseShellExecute = true });

    private void BrowseGame_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFolderDialog { Title = "اختر مجلد لعبة Atomic Heart" };
        if (dialog.ShowDialog(this) == true) GamePathBox.Text = dialog.FolderName;
    }

    private void BrowsePackage_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFolderDialog { Title = "اختر مجلد ملفات حزمة p12 الثلاثة بعد فك الضغط" };
        if (dialog.ShowDialog(this) == true) PackagePathBox.Text = dialog.FolderName;
    }

    private void Paths_Changed(object sender, System.Windows.Controls.TextChangedEventArgs e)
    {
        if (InstallButton is not null) UpdateButtons();
    }

    private void UpdateButtons()
    {
        var gameValid = false;
        var hasManifest = false;
        try { _ = installer.ModsPath(GamePathBox.Text.Trim()); gameValid = true; hasManifest = installer.HasManifest(GamePathBox.Text.Trim()); } catch { }
        var packagePresent = Directory.Exists(PackagePathBox.Text.Trim());
        GameBadge.Text = gameValid ? "مجلد اللعبة جاهز" : "اختر مجلد اللعبة";
        PackageBadge.Text = packagePresent ? "جاهزة للفحص" : "الحزمة غير مرفقة";
        InstallButton.IsEnabled = !busy && gameValid && packagePresent;
        CheckButton.IsEnabled = !busy;
        RemoveButton.IsEnabled = !busy && hasManifest;
        GameBrowse.IsEnabled = PackageBrowse.IsEnabled = GamePathBox.IsEnabled = PackagePathBox.IsEnabled = !busy;
    }

    private void Log(string text)
    {
        Dispatcher.Invoke(() =>
        {
            ActivityLog.AppendText(Environment.NewLine + "• " + text);
            ActivityLog.ScrollToEnd();
        });
    }

    private void SetStatus(string text, bool success)
    {
        StatusText.Text = text;
        StatusDot.Fill = new SolidColorBrush((Color)ColorConverter.ConvertFromString(success ? "#ADC394" : "#E6B65C"));
    }

    private async Task RunOperation(Action action, string success)
    {
        if (busy) return;
        busy = true;
        UpdateButtons();
        Progress.Visibility = Visibility.Visible;
        SetStatus("جارٍ تنفيذ العملية…", false);
        try
        {
            await Task.Run(action);
            SetStatus(success, true);
            Log(success);
        }
        catch (UnauthorizedAccessException)
        {
            SetStatus("تعذّر الوصول إلى المجلد", false);
            Log("Windows لا يسمح بالكتابة في هذا المجلد. تأكد من صلاحية الوصول إلى مجلد اللعبة ثم أعد المحاولة.");
        }
        catch (Exception ex)
        {
            SetStatus("توقفت العملية — راجع السجل", false);
            Log(ex.Message);
        }
        finally
        {
            busy = false;
            Progress.Visibility = Visibility.Collapsed;
            UpdateButtons();
        }
    }

    private void RequireGameClosed()
    {
        foreach (var name in new[] { "AtomicHeart", "AtomicHeart-Win64-Shipping" })
        {
            var processes = Process.GetProcessesByName(name);
            var running = processes.Length > 0;
            foreach (var process in processes) process.Dispose();
            if (running) throw new InvalidOperationException("أغلق لعبة Atomic Heart قبل تغيير ملفات التعريب.");
        }
    }

    private async void Install_Click(object sender, RoutedEventArgs e)
    {
        var game = GamePathBox.Text.Trim();
        var package = PackagePathBox.Text.Trim();
        await RunOperation(() => { RequireGameClosed(); installer.Install(game, package, Log); }, "التعريب جاهز — اختر الكورية داخل اللعبة");
    }

    private async void Remove_Click(object sender, RoutedEventArgs e)
    {
        if (MessageBox.Show(this, "إزالة ملفات التعريب التي يديرها التطبيق؟", "إزالة التعريب", MessageBoxButton.YesNo, MessageBoxImage.Question, MessageBoxResult.No, MessageBoxOptions.RtlReading) != MessageBoxResult.Yes) return;
        var game = GamePathBox.Text.Trim();
        await RunOperation(() => { RequireGameClosed(); installer.Uninstall(game, Log); }, "تمت إزالة التعريب");
    }

    private async void Check_Click(object sender, RoutedEventArgs e)
    {
        var game = GamePathBox.Text.Trim();
        var package = PackagePathBox.Text.Trim();
        await RunOperation(() =>
        {
            _ = installer.ModsPath(game);
            Log("مجلد اللعبة صحيح.");
            if (!string.IsNullOrEmpty(package)) { installer.VerifyPackage(package); Log("الحزم الثلاث مطابقة للحجم وSHA256 المعتمدين."); }
            if (installer.HasManifest(game)) { installer.VerifyInstalled(game); Log("ملفات التعريب المثبتة سليمة."); }
            else if (string.IsNullOrEmpty(package)) throw new InvalidOperationException("اختر مجلد حزمة التعريب لإكمال الفحص، أو استخدم الحزمة داخل مجلد payload في النسخة الكاملة.");
        }, "اكتمل فحص الملفات بنجاح");
    }

    private static string? DetectGame()
    {
        var libraries = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var steam = Registry.GetValue(@"HKEY_CURRENT_USER\Software\Valve\Steam", "SteamPath", null) as string;
        if (!string.IsNullOrWhiteSpace(steam)) libraries.Add(steam);
        libraries.Add(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), "Steam"));
        foreach (var library in libraries.ToArray())
        {
            var vdf = Path.Combine(library, "steamapps", "libraryfolders.vdf");
            try
            {
                if (!File.Exists(vdf)) continue;
                foreach (Match match in Regex.Matches(File.ReadAllText(vdf), "\"path\"\\s+\"([^\"]+)\""))
                    libraries.Add(match.Groups[1].Value.Replace("\\\\", "\\"));
            }
            catch (IOException) { }
            catch (UnauthorizedAccessException) { }
        }
        return libraries.Select(p => Path.Combine(p, "steamapps", "common", "Atomic Heart")).FirstOrDefault(p => File.Exists(Path.Combine(p, "AtomicHeart.exe")));
    }
}
