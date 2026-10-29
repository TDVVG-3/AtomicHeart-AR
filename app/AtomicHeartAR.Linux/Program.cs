using Avalonia;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Themes.Fluent;
using Avalonia.Styling;
using Avalonia.Threading;
using Avalonia.Media.Imaging;

namespace AtomicHeartAR;

internal static class Program
{
    [STAThread]
    public static void Main(string[] args) => AppBuilder.Configure<DesktopApp>().UsePlatformDetect().StartWithClassicDesktopLifetime(args);
}

public sealed class DesktopApp : Application
{
    public override void Initialize()
    {
        RequestedThemeVariant = ThemeVariant.Dark;
        Styles.Add(new FluentTheme());
    }
    public override void OnFrameworkInitializationCompleted()
    {
        if (ApplicationLifetime is IClassicDesktopStyleApplicationLifetime desktop)
        {
            var window = new InstallerWindow();
            desktop.MainWindow = window;
            if (desktop.Args?.FirstOrDefault() == "--smoke-test")
            {
                var timer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(2) };
                timer.Tick += (_, _) =>
                {
                    timer.Stop();
                    if (desktop.Args.Length > 1)
                    {
                        using var bitmap = new RenderTargetBitmap(new PixelSize((int)window.Bounds.Width, (int)window.Bounds.Height));
                        bitmap.Render(window);
                        bitmap.Save(desktop.Args[1]);
                    }
                    Console.WriteLine("GUI_SMOKE_PASS: Arabic installer window rendered");
                    desktop.Shutdown(0);
                };
                timer.Start();
            }
        }
        base.OnFrameworkInitializationCompleted();
    }
}
