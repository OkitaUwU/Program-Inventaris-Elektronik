program InventarisElektronik;
uses crt;

type
    Perangkat = record
        kode: string[10];
        nama: string[50];
        jumlah: integer;
        kondisi: string[20];
    end;

var
    dataFile: file of Perangkat;
    tmpPerangkat: Perangkat;
    pilihan: integer;
    fileName: string;

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

procedure TampilkanHeaderTabel;
begin
    writeln('------------------------------------------------------------------');
    writeln('| Kode       | Nama                       | Jumlah  | Kondisi    |');
    writeln('------------------------------------------------------------------');
end;

procedure TampilkanBarisTabel(p: Perangkat);
begin
    writeln('| ', p.kode:10, ' | ', p.nama:26, ' | ', p.jumlah:7, ' | ', p.kondisi:10, ' |');
end;

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
