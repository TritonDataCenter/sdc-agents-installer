{
    "release-name": "release-20110324"
  , "agents":
      [ {"repo": "atropos", "checkout": "origin/release-20110324"}
      , {"repo": "provisioner", "checkout": "origin/release-20110324"}
      , {"repo": "gzone_heartbeat", "name": "heartbeater", "checkout": "origin/release-20110324"}
      , {"repo": "dataset_manager", "checkout": "origin/release-20110324"}
      , {"repo": "cloud-analytics", "checkout": "20110324", "target": "pkg", "tarball": "build/pkg/*.tar.gz", "output": ""}
      , {"repo": "zonetracker", "checkout": "origin/release-20110324"}
      , {"repo": "smart-login", "checkout": "origin/release-20110324"}
      ]
}
