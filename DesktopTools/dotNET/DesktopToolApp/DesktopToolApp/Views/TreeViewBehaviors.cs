using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace DesktopTool
{
    public class TreeViewBehaviors
    {
        public static ICommand GetOnSelectedItemChanged(DependencyObject d)
        {
            return (ICommand)d.GetValue(OnSelectedItemChangedProperty);
        }

        public static void SetOnSelectedItemChanged(DependencyObject d, ICommand value)
        {
            d.SetValue(OnSelectedItemChangedProperty, value);
        }

        public static readonly DependencyProperty OnSelectedItemChangedProperty =
            DependencyProperty.RegisterAttached("OnSelectedItemChanged", typeof(ICommand), typeof(TreeViewBehaviors), new UIPropertyMetadata(null, OnSelectedItemChangedPropertyChanged));

        static void OnSelectedItemChangedPropertyChanged(DependencyObject d, DependencyPropertyChangedEventArgs args)
        {
            if (d is not TreeView treeView) {
                return;
            }
            if (args.NewValue is ICommand) {
                treeView.SelectedItemChanged += new RoutedPropertyChangedEventHandler<object>(OnTreeViewSelectedItemChanged);
            } else {
                treeView.SelectedItemChanged -= new RoutedPropertyChangedEventHandler<object>(OnTreeViewSelectedItemChanged);
            }
        }

        static void OnTreeViewSelectedItemChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
            if (e.OriginalSource is not TreeView treeView) {
                return;
            }
            var command = GetOnSelectedItemChanged(treeView);
            if (command == null) {
                return;
            }
            command.Execute(treeView.SelectedItem);
        }
    }
}
