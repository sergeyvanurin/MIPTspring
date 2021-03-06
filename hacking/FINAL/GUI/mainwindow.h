#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QLabel>
#include <QPushButton>
#include <QErrorMessage>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();
private slots:
    void on_File_choose_button_clicked();

    void on_Patch_button_clicked();
private:
    Ui::MainWindow *ui;
    QWidget* gif_window;
    QLabel* movie_label;
    QString filename;
    int Patcher(std::string filename);

};
#endif // MAINWINDOW_H
