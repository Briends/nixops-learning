# NixOps Learning

Currently broken.

```txt
typeguard.TypeCheckError: value of key '/dev/disk/by-id/scsi-0Google_PersistentDisk_n-15678c307b9c11eeabf8aa3cacb17f69-hello-root' of nixops.resources.ResourceEval is not an instance of nixops_gcp.backends.options.GCEDiskOptions
```

## Reproduce

1. Adjust the `keyjson` value.
2. Run `nixops create -d hello`.
3. Run `nixops list`.
