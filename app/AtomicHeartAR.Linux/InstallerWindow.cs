using System.Diagnostics;
using Avalonia;
using Avalonia.Controls;
using Avalonia.Layout;
using Avalonia.Media;
using Avalonia.Platform.Storage;
using Avalonia.Threading;

namespace AtomicHeartAR;

public sealed class InstallerWindow : Window
{
    private readonly ModInstaller installer = new();
    private readonly TextBox game = new() { Watermark = "مجلد اللعبة الذي يحتوي على AtomicHeart.exe", FlowDirection = FlowDirection.LeftToRight };
    private readonly TextBox package = new() { FlowDirection = FlowDirection.LeftToRight };
    private readonly TextBlock status = Text("اختر مجلد اللعبة للبدء", 15, "#ADC394");
    private readonly TextBlock log = Text("جاهز · لا يلزم تشغيل التطبيق بصلاحيات root", 12, "#AAB6A3");
    private readonly ProgressBar progress = new() { IsIndeterminate = true, IsVisible = false, Height = 3 };
    private readonly List<Control> inputs = new();
    private readonly Queue<string> messages = new();
    private bool busy;

    public InstallerWindow()
    {
        Title = "AtomicHeart-AR · 1.0.2";
        Width = 1060; Height = 770; MinWidth = 720; MinHeight = 560;
        Background = Brush.Parse("#121713"); Foreground = Brush.Parse("#EEE9D8");
        FontFamily = new FontFamily("DejaVu Sans"); FlowDirection = FlowDirection.RightToLeft;
        WindowStartupLocation = WindowStartupLocation.CenterScreen;
        var page = new StackPanel { Spacing = 18, Margin = new Thickness(32) };
        page.Children.Add(Text("ATOMIC HEART  /  AR", 17, "#AFC79A"));
        page.Children.Add(Text("عالمٌ آخر. بلغتك.", 38, "#EEE9D8"));
        page.Children.Add(Text("مثبّت التعريب العربي  ·  1.0.2  ·  LINUX / STEAM PROTON", 13, "#AFC79A"));
        page.Children.Add(Text("ثبّت التعريب، افحص ملفاته، أو أزله بأمان. اختر مجلد اللعبة في مكتبة Steam.", 15));
        page.Children.Add(Card("01  مجلد اللعبة", game, async () => await Pick(game)));
        page.Children.Add(Card("02  حزمة التعريب", package, async () => await Pick(package)));
        var actions = new StackPanel { Orientation = Orientation.Horizontal, Spacing = 10 };
        var install = Button("تثبيت / تحديث التعريب", async () =>
        {
            var root = LinuxGamePaths.ResolveRoot(game.Text?.Trim() ?? ""); var source = package.Text?.Trim() ?? "";
            await Run(() => { LinuxGamePaths.RequireClosed(); installer.Install(root, source, Log); }, "التعريب جاهز — اختر اللغة الكورية داخل اللعبة");
        });
        install.Background = Brush.Parse("#E65043"); install.Foreground = Brushes.White;
        actions.Children.Add(install);
        actions.Children.Add(Button("فحص الملفات", async () =>
        {
            var root = LinuxGamePaths.ResolveRoot(game.Text?.Trim() ?? ""); var source = package.Text?.Trim() ?? "";
            await Run(() =>
            {
                _ = installer.ModsPath(root); installer.VerifyPackage(source);
                if (installer.HasManifest(root)) installer.VerifyInstalled(root);
            }, "الحزمة سليمة ومجلد اللعبة صحيح");
        }));
        actions.Children.Add(Button("إزالة التعريب", async () =>
        {
            if (!await Confirm()) return;
            var root = LinuxGamePaths.ResolveRoot(game.Text?.Trim() ?? "");
            await Run(() => { LinuxGamePaths.RequireClosed(); installer.Uninstall(root, Log); }, "تمت إزالة ملفات التعريب المسجّلة");
        }));
        page.Children.Add(actions); page.Children.Add(progress); page.Children.Add(status);
        page.Children.Add(new Border { Background = Brush.Parse("#1B231B"), CornerRadius = new CornerRadius(10), Padding = new Thickness(18), Child = log });
        page.Children.Add(Text("بعد التثبيت: اختر Korean للغة النصوص. أبقِ لغة الصوت كما تحب. أغلق اللعبة قبل التثبيت أو الإزالة.", 13, "#C2CBB8"));
        page.Children.Add(Text("التثبيت على Steam / Proton. اللعبة نفسها تعمل عبر Proton؛ التطبيق يعمل مباشرة على لينكس.", 12, "#95A28D"));
        var link = Button("المشروع وطريقة الاستخدام ↗", () =>
        {
            Process.Start(new ProcessStartInfo("xdg-open") { ArgumentList = { "https://github.com/TDVVG-3/AtomicHeart-AR" }, UseShellExecute = false });
            return Task.CompletedTask;
        });
        page.Children.Add(link);
        Content = new ScrollViewer { Content = page };
        Closing += (_, e) => { if (busy) { e.Cancel = true; Log("انتظر اكتمال العملية أو الاسترجاع قبل الإغلاق."); } };
        Opened += async (_, _) =>
        {
            package.Text = Path.Combine(AppContext.BaseDirectory, "payload");
            var found = await Task.Run(LinuxGamePaths.Detect);
            if (!busy && string.IsNullOrWhiteSpace(game.Text)) game.Text = found ?? "";
        };
    }

    private static TextBlock Text(string value, double size, string color = "#EEE9D8") => new()
    { Text = value, FontSize = size, Foreground = Brush.Parse(color), TextWrapping = TextWrapping.Wrap };
    private Button Button(string label, Func<Task> action)
    {
        var button = new Button { Content = label, Padding = new Thickness(18, 12), CornerRadius = new CornerRadius(7) };
        button.Click += async (_, _) => { try { await action(); } catch (Exception ex) { Log(ex.Message); } };
        inputs.Add(button); return button;
    }
    private Border Card(string title, TextBox box, Func<Task> browse)
    {
        inputs.Add(box);
        var content = new StackPanel { Spacing = 10 };
        content.Children.Add(Text(title, 17, "#AFC79A"));
        var row = new DockPanel { LastChildFill = true };
        var button = Button("اختيار المجلد", browse); DockPanel.SetDock(button, Dock.Left);
        button.Margin = new Thickness(0, 0, 10, 0); row.Children.Add(button); row.Children.Add(box);
        content.Children.Add(row);
        return new Border { Background = Brush.Parse("#1B231B"), BorderBrush = Brush.Parse("#364431"), BorderThickness = new Thickness(1), CornerRadius = new CornerRadius(12), Padding = new Thickness(18), Child = content };
    }
    private async Task Pick(TextBox box)
    {
        var folders = await StorageProvider.OpenFolderPickerAsync(new FolderPickerOpenOptions { Title = "اختر المجلد", AllowMultiple = false });
        var path = folders.FirstOrDefault()?.TryGetLocalPath();
        if (path is not null) box.Text = LinuxGamePaths.ResolveRoot(path);
    }
    private void Log(string message) => Dispatcher.UIThread.Post(() =>
    {
        messages.Enqueue(message);
        while (messages.Count > 5) messages.Dequeue();
        log.Text = string.Join(Environment.NewLine, messages.Select(x => "• " + x));
    });
    private async Task Run(Action action, string success)
    {
        if (busy) return;
        busy = true; foreach (var control in inputs) control.IsEnabled = false;
        status.Text = "جارٍ تنفيذ العملية…"; progress.IsVisible = true;
        try { await Task.Run(action); status.Text = success; Log(success); }
        catch (Exception ex) { status.Text = "لم تكتمل العملية — راجع الرسالة"; Log(ex.Message); }
        finally { busy = false; progress.IsVisible = false; foreach (var control in inputs) control.IsEnabled = true; }
    }
    private async Task<bool> Confirm()
    {
        var dialog = new Window { Title = "إزالة التعريب", Width = 440, Height = 190, CanResize = false, WindowStartupLocation = WindowStartupLocation.CenterOwner, FlowDirection = FlowDirection.RightToLeft };
        var body = new StackPanel { Margin = new Thickness(24), Spacing = 16 };
        body.Children.Add(Text("إزالة ملفات التعريب المسجّلة في هذا المجلد؟", 16));
        var actions = new StackPanel { Orientation = Orientation.Horizontal, Spacing = 16 };
        var yes = new Button { Content = "إزالة" }; yes.Click += (_, _) => dialog.Close(true);
        var no = new Button { Content = "إلغاء" }; no.Click += (_, _) => dialog.Close(false);
        actions.Children.Add(no); actions.Children.Add(yes); body.Children.Add(actions); dialog.Content = body;
        dialog.Opened += (_, _) => no.Focus();
        return await dialog.ShowDialog<bool>(this);
    }
}
