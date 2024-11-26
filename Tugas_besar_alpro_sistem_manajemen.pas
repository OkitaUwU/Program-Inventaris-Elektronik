program InventarisPerangkatElektronik;
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
// - kondisi: Kondisi perangkat (misalnya, "baik", "rusak", "lama")

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

// Prosedur untuk menampilkan menu utama
procedure TampilkanMenu;
begin
    clrscr;
    writeln('===== SISTEM INVENTARIS PERANGKAT ELEKTRONIK =====');
    writeln('1. Tambah Perangkat');
    writeln('2. Tampilkan Semua Perangkat');
    writeln('3. Cari Perangkat');
    writeln('4. Edit Perangkat');
    writeln('5. Hapus Perangkat');
    writeln('6. Tulis ke File');
    writeln('0. Keluar');
    writeln('==================================================');
    write('Pilih menu (0-6): ');
end;

// Prosedur untuk menampilkan header tabel
procedure TampilkanHeaderTabel;
begin
    writeln('------------------------------------------------------------------');
    writeln('| Kode       | Nama                       | Jumlah  | Kondisi    |');
    writeln('------------------------------------------------------------------');
end;

// Prosedur untuk menampilkan data perangkat dalam tabel
procedure TampilkanBarisTabel(p: Perangkat);
begin
    writeln('| ', p.kode:10, ' | ', p.nama:26, ' | ', p.jumlah:7, ' | ', p.kondisi:10, ' |');
end;

// Prosedur untuk menampilkan perangkat secara rekursif
procedure TampilkanPerangkatPagingRekursif(halaman, perHalaman, total: Integer);
var
    i, startIdx, endIdx: Integer;
    key: char;
begin
    clrscr;
    writeln('=== DAFTAR PERANGKAT (Halaman ', halaman, '/', (total div perHalaman) + 1, ') ==='); // mengatur halaman
    TampilkanHeaderTabel;

    startIdx := (halaman - 1) * perHalaman;
    endIdx := startIdx + perHalaman - 1;

    for i := startIdx to endIdx do
    begin
        if i >= total then
            break;
        seek(dataFile, i); // mencari data
        read(dataFile, tmpPerangkat); // membaca data
        TampilkanBarisTabel(tmpPerangkat); // memanggil baris tabel
    end;

    writeln('------------------------------------------------------------------');
    writeln('[P] Sebelumnya  [N] Berikutnya  [Q] Keluar'); // pilihan berialih halaman atau keluar
    key := upcase(ReadKey);

    case key of
        'P': 
            if halaman > 1 then
                TampilkanPerangkatPagingRekursif(halaman - 1, perHalaman, total); // kembali ke halaman sebelumnya
        'N': 
            if halaman * perHalaman < total then
                TampilkanPerangkatPagingRekursif(halaman + 1, perHalaman, total); // membuka halaman berikutnya
        'Q': // keluar  dari fitur menampilkan semua data
            begin
                writeln('Tekan Enter untuk keluar.');
                readln;  // Menunggu input Enter untuk keluar
                exit;    // Keluar dari prosedur jika 'Q' ditekan
            end;
    end;
end;

// Prosedur untuk menambah perangkat baru

procedure TambahPerangkat;
var
    konfirmasi: char;
    valid: boolean;
begin
    clrscr;
    writeln('=== TAMBAH PERANGKAT ===');
    
    // Validasi untuk input kode perangkat
    repeat
        write('Masukkan Kode Perangkat: ');
        readln(tmpPerangkat.kode);
        if tmpPerangkat.kode = '' then
            writeln('Kode perangkat tidak boleh kosong!');
    until tmpPerangkat.kode <> ''; // Memastikan kode tidak kosong

    // Validasi untuk input nama perangkat
    repeat
        write('Masukkan Nama Perangkat: ');
        readln(tmpPerangkat.nama);
        if tmpPerangkat.nama = '' then
            writeln('Nama perangkat tidak boleh kosong!');
    until tmpPerangkat.nama <> ''; // Memastikan nama tidak kosong

    // Validasi untuk input jumlah perangkat
    valid := false;
    repeat
        write('Masukkan Jumlah: ');
        readln(tmpPerangkat.jumlah);
        if (tmpPerangkat.jumlah <= 0) then
            writeln('Jumlah perangkat harus lebih besar dari 0!');
        valid := (tmpPerangkat.jumlah > 0);
    until valid; // Memastikan jumlah perangkat valid

    // Validasi untuk input kondisi perangkat
    repeat
        write('Masukkan Kondisi: ');
        readln(tmpPerangkat.kondisi);
        if tmpPerangkat.kondisi = '' then
            writeln('Kondisi perangkat tidak boleh kosong!');
    until tmpPerangkat.kondisi <> ''; // Memastikan kondisi tidak kosong

    writeln;
    writeln('Data Perangkat yang Akan Ditambahkan:');
    TampilkanHeaderTabel; // menanggil header tabel
    TampilkanBarisTabel(tmpPerangkat); // memanggil baris tabel
    writeln('------------------------------------------------------------------');

    write('Apakah Anda yakin ingin menambahkan perangkat ini? (Y/N): '); // pilihan menambahkan perangkat
    readln(konfirmasi);
    
    if (konfirmasi = 'Y') or (konfirmasi = 'y') then // mengkonfirmasi y
    begin
        seek(dataFile, filesize(dataFile)); // mencari data
        write(dataFile, tmpPerangkat); // menuliskan data
        writeln('Data berhasil ditambahkan!');
    end
    else
        writeln('Penambahan perangkat dibatalkan.');
    writeln('Klik Enter untuk kembali ke menu.');
    readln;
end;

// Fungsi untuk mencari perangkat berdasarkan kode secara rekursif
function CariPerangkatRekursif(kode: string; posisi: Integer): Integer;
begin
    reset(dataFile);
    seek(dataFile, posisi);
    if not eof(dataFile) then
    begin
        read(dataFile, tmpPerangkat);
        if tmpPerangkat.kode = kode then
        begin
            CariPerangkatRekursif := posisi; // Kode ditemukan, kembalikan posisi
            exit;
        end
        else
            CariPerangkatRekursif := CariPerangkatRekursif(kode, posisi + 1); // Rekursi ke perangkat berikutnya
    end
    else
        CariPerangkatRekursif := -1; // Tidak ditemukan
end;

// Prosedur untuk mencari dan menampilkan perangkat
procedure CariDanTampilkanPerangkat;
var
    kode: string;
    posisi: Integer;
    lanjutCari: char;
begin
    repeat
        clrscr;
        write('Masukkan Kode Perangkat yang dicari: ');
        readln(kode);

        posisi := CariPerangkatRekursif(kode, 0);
        if posisi >= 0 then
        begin
            writeln('Perangkat ditemukan:');
            TampilkanHeaderTabel;
            seek(dataFile, posisi); // mencari data
            read(dataFile, tmpPerangkat); // membaca data
            TampilkanBarisTabel(tmpPerangkat); // memanggil baris tabel
            writeln('------------------------------------------------------------------');
        end
        else
            writeln('Perangkat tidak ditemukan!'); // pemberitahuan perangkat ditemukan
        
        writeln;
        write('Ingin mencari perangkat lain? (Y/N): '); // pilihan untuk mencari perangkat lain
        readln(lanjutCari); // lanjut mencari
    until (lanjutCari = 'N') or (lanjutCari = 'n'); // berhenti mencari
    writeln('Klik Enter untuk kembali ke menu.');
    readln;
end;

// Prosedur untuk mengedit perangkat
procedure EditPerangkat;
var
    kode: string;
    posisi: Integer;
    lanjutEdit: char;
begin
    clrscr;
    write('Masukkan Kode Perangkat yang akan diedit: ');
    readln(kode); // masukkan kode yang sudah tersimpan
    
    posisi := CariPerangkatRekursif(kode, 0); // memanggil cariPeraangkatRekursif
    if posisi >= 0 then
    begin
        writeln('Data Perangkat Ditemukan:');
        TampilkanHeaderTabel;
        seek(dataFile, posisi);
        read(dataFile, tmpPerangkat);
        TampilkanBarisTabel(tmpPerangkat);
        writeln('------------------------------------------------------------------');
        
        writeln;
        write('Apakah Anda ingin mengedit perangkat ini? (Y/N): '); // pilihan apakah ingin mengedit data
        readln(lanjutEdit); 
        if (lanjutEdit = 'N') or (lanjutEdit = 'n') then 
        begin
            writeln('Edit perangkat dibatalkan.'); // pengeditan dibatalkan
            writeln('Klik Enter untuk kembali ke menu.');
            readln;
            Exit;
        end;

        writeln('Masukkan data baru:');
        write('Masukkan Nama Baru: '); readln(tmpPerangkat.nama); // mengganti nama baru
        write('Masukkan Jumlah Baru: '); readln(tmpPerangkat.jumlah); // mengganti jumlah baru
        write('Masukkan Kondisi Baru: '); readln(tmpPerangkat.kondisi); // mengganti kondisi baru
        
        seek(dataFile, posisi);
        write(dataFile, tmpPerangkat);
        writeln('Data berhasil diupdate!');
    end
    else
        writeln('Perangkat tidak ditemukan!');
    writeln('Klik Enter untuk kembali ke menu.');
    readln;
end;

// Prosedur untuk menghapus perangkat
procedure HapusPerangkat;
var
    kode: string;
    posisi: Integer;
    tempFile: file of Perangkat;
    lanjutHapus: char;
begin
    clrscr;
    write('Masukkan Kode Perangkat yang akan dihapus: ');
    readln(kode);
    
    posisi := CariPerangkatRekursif(kode, 0); // memanggil cariPerangkatRekursif
    if posisi >= 0 then
    begin
        writeln('Data Perangkat Ditemukan:');
        TampilkanHeaderTabel;
        seek(dataFile, posisi); // mencari data
        read(dataFile, tmpPerangkat); // membaca data
        TampilkanBarisTabel(tmpPerangkat); // memanggil baris tabel
        writeln('------------------------------------------------------------------');

        writeln;
        write('Apakah Anda yakin ingin menghapus perangkat ini? (Y/N): '); // pilihan apakah ingin menghapus data
        readln(lanjutHapus);
        if (lanjutHapus = 'N') or (lanjutHapus = 'n') then
        begin
            writeln('Penghapusan perangkat dibatalkan.'); // penghapusan dibatalkan
            writeln('Klik Enter untuk kembali ke menu.');
            readln;
            Exit; // keluar
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
        
        close(dataFile); // menutup datafile
        close(tempFile); // menutup tempfile
        
        erase(dataFile); // menghapus datafile
        rename(tempFile, fileName); // mengganti nama tempfile dan filename
        assign(dataFile, fileName); // menetapkan datafile dan filename
        reset(dataFile); // mereset datafile
        
        writeln('Data berhasil dihapus!');
    end
    else
        writeln('Perangkat tidak ditemukan!');
    writeln('Klik Enter untuk kembali ke menu.');
    readln;
end;

// Prosedur untuk menulis data perangkat ke file output
procedure TulisKeFile;
var
    outputFile: TextFile;
begin
    assign(outputFile, 'output_perangkat.txt');
    rewrite(outputFile);  // Menulis ke file output_perangkat.txt

    // Menulis header tabel
    writeln(outputFile, '------------------------------------------------------------------');
    writeln(outputFile, '| Kode       | Nama                       | Jumlah  | Kondisi    |');
    writeln(outputFile, '------------------------------------------------------------------');

    // Menulis data perangkat
    reset(dataFile);
    while not eof(dataFile) do
    begin
        read(dataFile, tmpPerangkat);
        writeln(outputFile, '| ', tmpPerangkat.kode:10, ' | ', tmpPerangkat.nama:26, ' | ', tmpPerangkat.jumlah:7, ' | ', tmpPerangkat.kondisi:10, ' |');
    end;
    clrscr;
    writeln(outputFile, '------------------------------------------------------------------');
    close(outputFile);  // Menutup file output
    writeln('Data telah berhasil ditulis ke file output_perangkat.txt'); // pemberitahuan data berhasil ditulis di file output_perangkat.txt
    writeln('Klik Enter untuk kembali ke menu.'); // kembali ke menu
    readln;
end;

// Main program
begin
    fileName := 'inventaris.data';  // Nama file untuk menyimpan data perangkat
    assign(dataFile, fileName);
    
    // Cek apakah file sudah ada, jika tidak, buat file baru
    {$I-}
    reset(dataFile);
    {$I+}
    if IOResult <> 0 then
        rewrite(dataFile);

    repeat
        TampilkanMenu;
        readln(pilihan);
        
        case pilihan of
            1: TambahPerangkat;              // Menu untuk menambah perangkat
            2: TampilkanPerangkatPagingRekursif(1, 5, filesize(dataFile)); // Menu untuk menampilkan semua perangkat
            3: CariDanTampilkanPerangkat;    // Menu untuk mencari perangkat
            4: EditPerangkat;                // Menu untuk mengedit perangkat
            5: HapusPerangkat;               // Menu untuk menghapus perangkat
            6: TulisKeFile;                  // Menu untuk menulis ke file output
        end;
    until pilihan = 0;  // Keluar dari program jika memilih 0
    if pilihan = 0 then
      begin
        clrscr;
        writeln('terima kasih telah menggunakan program kami!');
        readkey;
      end;
    close(dataFile);  // Menutup file data
end.
