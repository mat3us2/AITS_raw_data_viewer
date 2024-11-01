### DO NOT RUN
### Rdata has best compression still
if(FALSE) {
files <- dir("data", pattern = ".Rdata$", full.names = TRUE)

purrr::walk2(
  files, 
  sprintf("%s.qs2", fs::path_ext_remove(files)), ~{
    na <- load(..1)
    qs2::qs_save(get(a), ..2, nthreads = 4L)
    print(identical(get(a), qs2::qs_read(..2)))
  }
)

purrr::walk2(
  files, 
  sprintf("%s.qs", fs::path_ext_remove(files)), ~{
    na <- load(..1)
    qs::qsave(get(a), ..2, nthreads = 4L)
    print(identical(get(a), qs::qread(..2)))
  }
)

if(!codec_is_available("gzip")) stop("Modify script to use parquet without gzip compression.")
  
purrr::walk2(
  files, 
  sprintf("%s.gz.parquet", fs::path_ext_remove(files)), ~{
    na <- load(..1)
    arrow::write_parquet(get(a), ..2, compression = "gzip")
    print(identical(get(a), arrow::read_parquet(..2)))
  }
)

files <- dir("data", pattern = ".qs$", full.names = TRUE)
fs::file_delete(files)
files <- dir("data", pattern = ".qs2$", full.names = TRUE)
fs::file_delete(files)
files <- dir("data", pattern = ".gz.parquet$", full.names = TRUE)
fs::file_delete(files)
}