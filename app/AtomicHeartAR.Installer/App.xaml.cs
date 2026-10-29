using System.Windows;

namespace AtomicHeartAR;

public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        DispatcherUnhandledException += (_, args) =>
        {
            try { System.IO.File.WriteAllText(System.IO.Path.Combine(AppContext.BaseDirectory, "AtomicHeartAR-error.log"), args.Exception.ToString()); } catch { }
            MessageBox.Show("تعذّر إكمال العملية.\n" + args.Exception.GetBaseException().Message, "AtomicHeart-AR", MessageBoxButton.OK, MessageBoxImage.Error);
            args.Handled = true;
        };
        base.OnStartup(e);
    }
}
