storage "file" {
    path = "/vault/data"
}

api_addr = "https://127.0.0.1:8202"
cluster_addr  = "https://127.0.0.1:8203"

listener "tcp" {
    address = "127.0.0.1:8202"
    cluster_address = "127.0.0.1:8203"
    tls_disable = 1
}
disable_mlock = true