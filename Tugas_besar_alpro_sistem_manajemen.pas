program InventarisElektronik;
uses crt;

type
    Perangkat = record
        kode: string[10];
        nama: string[50];
        jumlah: integer;
        kondisi: string[20];
    end;

// Definisi tipe data "Perangkat" menggunakan record yang terdiri dari:
// - kode: Kode unik perangkat (maksimal 10 karakter)
// - nama: Nama perangkat (maksimal 50 karakter)
// - jumlah: Jumlah perangkat dalam inventaris
// - kondisi: Kondisi perangkat (misalnya, "baik", "rusak")

var
    dataFile: file of Perangkat;
    tmpPerangkat: Perangkat;
    pilihan: integer;
    fileName: string;

// Variabel global yang digunakan:
// - dataFile: File yang berisi data semua perangkat
// - tmpPerangkat: Record sementara untuk menyimpan data perangkat yang sedang diolah
// - pilihan: Pilihan menu dari pengguna
// - fileName: Nama file yang menyimpan data perangkat

procedure TampilkanMenu;
begin
    clrscr;
    writeln('===== SISTEM INVENTARIS PERANGKAT ELEKTRONIK =====');
    writeln('1. Tambah Perangkat');
    writeln('2. Tampilkan Semua Perangkat');
    writeln('3. Cari Perangkat');
    writeln('4. Edit Perangkat');
    writeln('5. Hapus Perangkat');
    writeln('0. Keluar');
    writeln('=============================================');
    write('Pilih menu (0-5): ');
end;

// Prosedur TampilkanMenu menampilkan menu utama dengan pilihan untuk menambah, melihat, mencari, mengedit, atau menghapus perangkat.
// Pengguna dapat memilih salah satu opsi dengan memasukkan angka dari 0 sampai 5.

procedure TampilkanHeaderTabel;
begin
    writeln('------------------------------------------------------------------');
    writeln('| Kode       | Nama                       | Jumlah  | Kondisi    |');
    writeln('------------------------------------------------------------------');
end;

// Prosedur TampilkanHeaderTabel menampilkan header tabel untuk data perangkat elektronik.

procedure TampilkanBarisTabel(p: Perangkat);
begin
    writeln('| ', p.kode:10, ' | ', p.nama:26, ' | ', p.jumlah:7, ' | ', p.kondisi:10, ' |');
end;

// Prosedur TampilkanBarisTabel menampilkan data satu perangkat dalam format tabel.

procedure TambahPerangkat;
var
    konfirmasi: char;
begin
    clrscr;
    writeln('=== TAMBAH PERANGKAT ===');
    
    write('Masukkan Kode Perangkat: ');
    readln(tmpPerangkat.kode);
    write('Masukkan Nama Perangkat: ');
    readln(tmpPerangkat.nama);
    write('Masukkan Jumlah: ');
    readln(tmpPerangkat.jumlah);
    write('Masukkan Kondisi: ');
    readln(tmpPerangkat.kondisi);

    writeln;
    writeln('Data Perangkat yang Akan Ditambahkan:');
    TampilkanHeaderTabel;
    TampilkanBarisTabel(tmpPerangkat);
    writeln('------------------------------------------------------------------');

    write('Apakah Anda yakin ingin menambahkan perangkat ini? (Y/N): ');
    readln(konfirmasi);
    
    if (konfirmasi = 'Y') or (konfirmasi = 'y') then
    begin
        seek(dataFile, filesize(dataFile));
        write(dataFile, tmpPerangkat);
        writeln('Data berhasil ditambahkan!');
    end
    else
        writeln('Penambahan perangkat dibatalkan.');
    writeln('Klik Enter untuk kembali ke menu.');
    readln;
end;

// Prosedur TambahPerangkat meminta pengguna memasukkan data perangkat baru,
// kemudian menampilkan data tersebut untuk konfirmasi sebelum disimpan ke file.

procedure TampilkanPerangkat;
begin
    clrscr;
    writeln('=== DAFTAR PERANGKAT ===');
    TampilkanHeaderTabel;
    reset(dataFile);
    while not eof(dataFile) do
    begin
        read(dataFile, tmpPerangkat);
        TampilkanBarisTabel(tmpPerangkat);
    end;
    writeln('------------------------------------------------------------------');
    writeln('Klik Enter untuk kembali ke menu.');
    readln;
end;

// Prosedur TampilkanPerangkat menampilkan seluruh data perangkat yang ada di dalam file.

function CariPerangkat(kode: string): integer;
var
    posisi: integer;
begin
    posisi := -1;
    reset(dataFile);
    while not eof(dataFile) do
    begin
        read(dataFile, tmpPerangkat);
        if tmpPerangkat.kode = kode then
        begin
            posisi := filepos(dataFile) - 1;
            break;
        end;
    end;
    CariPerangkat := posisi;
end;

// Fungsi CariPerangkat mencari perangkat berdasarkan kode.
// Jika ditemukan, fungsi mengembalikan posisi perangkat dalam file; jika tidak, mengembalikan -1.

procedure CariDanTampilkanPerangkat;
var
    kode: string;
    posisi: integer;
    lanjutCari: char;
begin
    repeat
        clrscr;
        write('Masukkan Kode Perangkat yang dicari: ');
        readln(kode);

        posisi := CariPerangkat(kode);
        if posisi >= 0 then
        begin
            writeln('Perangkat ditemukan:');
            TampilkanHeaderTabel;
            TampilkanBarisTabel(tmpPerangkat);
            writeln('------------------------------------------------------------------');
        end
        else
            writeln('Perangkat tidak ditemukan!');
        
        writeln;
        write('Ingin mencari perangkat lain? (Y/N): ');
        readln(lanjutCari);
    until (lanjutCari = 'N') or (lanjutCari = 'n');
    writeln('Klik Enter untuk kembali ke menu.');
    readln;
end;

// Prosedur CariDanTampilkanPerangkat memungkinkan pengguna mencari perangkat berdasarkan kode
// dan menampilkan hasil pencarian. Jika perangkat tidak ditemukan, ditampilkan pesan error.

procedure EditPerangkat;
var
    kode: string;
    posisi: integer;
    lanjutEdit: char;
begin
    clrscr;
    write('Masukkan Kode Perangkat yang akan diedit: ');
    readln(kode);
    
    posisi := CariPerangkat(kode);
    if posisi >= 0 then
    begin
        writeln('Data Perangkat Ditemukan:');
        TampilkanHeaderTabel;
        TampilkanBarisTabel(tmpPerangkat);
        writeln('------------------------------------------------------------------');
        
        writeln;
        write('Apakah Anda ingin mengedit perangkat ini? (Y/N): ');
        readln(lanjutEdit);
        if (lanjutEdit = 'N') or (lanjutEdit = 'n') then
        begin
            writeln('Edit perangkat dibatalkan.');
            writeln('Klik Enter untuk kembali ke menu.');
            readln;
            Exit;
        end;

        writeln('Masukkan data baru (kosongkan jika tidak ingin mengubah):');
        write('Masukkan Nama Baru: '); readln(tmpPerangkat.nama);
        write('Masukkan Jumlah Baru: '); readln(tmpPerangkat.jumlah);
        write('Masukkan Kondisi Baru: '); readln(tmpPerangkat.kondisi);
        
        seek(dataFile, posisi);
        write(dataFile, tmpPerangkat);
        writeln('Data berhasil diupdate!');
    end
    else
        writeln('Perangkat tidak ditemukan!');
    writeln('Klik Enter untuk kembali ke menu.');
    readln;
end;

// Prosedur EditPerangkat memungkinkan pengguna mengedit data perangkat berdasarkan kode yang dimasukkan.
// Jika ditemukan, pengguna bisa mengubah nama, jumlah, atau kondisi perangkat.

procedure HapusPerangkat;
var
    kode: string;
    posisi: integer;
    tempFile: file of Perangkat;
    lanjutHapus: char;
begin
    clrscr;
    write('Masukkan Kode Perangkat yang akan dihapus: ');
    readln(kode);
    
    posisi := CariPerangkat(kode);
    if posisi >= 0 then
    begin
        writeln('Data Perangkat Ditemukan:');
        TampilkanHeaderTabel;
        TampilkanBarisTabel(tmpPerangkat);
        writeln('------------------------------------------------------------------');

        writeln;
        write('Apakah Anda yakin ingin menghapus perangkat ini? (Y/N): ');
        readln(lanjutHapus);
        if (lanjutHapus = 'N') or (lanjutHapus = 'n') then
        begin
            writeln('Penghapusan perangkat dibatalkan.');
            writeln('Klik Enter untuk kembali ke menu.');
            readln;
            Exit;
        end;

        assign(tempFile, 'temp.dat');
        rewrite(tempFile);
        
        reset(dataFile);
        while not eof(dataFile) do
        begin
            read(dataFile, tmpPerangkat);
            if tmpPerangkat.kode <> kode then
                write(tempFile, tmpPerangkat);
        end;
        
        close(dataFile);
        close(tempFile);
        
        erase(dataFile);
        rename(tempFile, fileName);
        assign(dataFile, fileName);
        reset(dataFile);
        
        writeln('Data berhasil dihapus!');
    end
    else
        writeln('Perangkat tidak ditemukan!');
    writeln('Klik Enter untuk kembali ke menu.');
    readln;
end;

// Prosedur HapusPerangkat memungkinkan pengguna menghapus data perangkat berdasarkan kode yang dimasukkan.
// Jika ditemukan

begin
    fileName := 'inventaris.dat';
    assign(dataFile, fileName);
    {$I-}
    reset(dataFile);
    {$I+}
    if IOResult <> 0 then
        rewrite(dataFile);
        
    repeat
        TampilkanMenu;
        readln(pilihan);
        
        case pilihan of
            1: TambahPerangkat;
            2: TampilkanPerangkat;
            3: CariDanTampilkanPerangkat;
            4: EditPerangkat;
            5: HapusPerangkat;
        end;
    until pilihan = 0;
    
    close(dataFile);
end.
