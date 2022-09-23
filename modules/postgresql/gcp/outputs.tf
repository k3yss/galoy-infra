output "instance_name" {
  value = google_sql_database_instance.instance.name
}

output "private_ip" {
  value = google_sql_database_instance.instance.private_ip_address
}

output "creds" {
  value = [
    for db in local.databases : {
      db_name  = db
      user     = module.database[db].user
      password = module.database[db].password
    }
  ]
  sensitive = true
}