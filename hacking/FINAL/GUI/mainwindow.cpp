#include <iostream>
#include <string>
#include <QFileDialog>
#include <QObject>
#include <fstream>
#include <cstdio>

#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_File_choose_button_clicked()
{
    QFileDialog file_dialog(this);
    file_dialog.setFileMode(QFileDialog::ExistingFile);
    file_dialog.setNameFilter("COM Files (*.com)");

    if (file_dialog.exec())
    {
        filename = file_dialog.selectedFiles()[0];
    }
    ui->adress_bar->setText(filename);
    ui->Patch_button->setEnabled(true);
}

void MainWindow::on_Patch_button_clicked()
{
    std::string path = filename.toStdString();
    if (Patcher(path))
    {
        ui->label_under_button->setStyleSheet("QLabel {color:rgb(255,0,0)}");
        ui->label_under_button->setText("Error opening a file :(");
    }
    else
    {
        ui->label_under_button->setStyleSheet("QLabel {color:rgb(0,255,0)}");
        ui->label_under_button->setText("Successfuly patched");
    }

}

int MainWindow::Patcher(std::string filename)
{
    FILE* binary_executable = nullptr;
    binary_executable = fopen(filename.c_str(), "r+");

    if (!binary_executable)
    {
        return 1;
    }

    unsigned int first_byte_to_patch = 0x33;
    char first_patch_value = 0x74;

    unsigned int second_byte_to_patch = 0x54;
    char second_patch_value[2] = {(char)0xAC, (char)0xBC};

    fseek(binary_executable, first_byte_to_patch, SEEK_SET);
    fwrite(&first_patch_value, 1, 1, binary_executable);

    fseek(binary_executable, second_byte_to_patch, SEEK_SET);
    fwrite(second_patch_value, 1, 2, binary_executable);

    fclose(binary_executable);

    return 0;
}