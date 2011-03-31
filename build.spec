{
    "release-name": "release-20110331"
  , "agents":
      [ {"repo": "atropos", "checkout": "origin/release-20110331"}
      , {"repo": "provisioner", "checkout": "origin/release-20110331"}
      , {"repo": "gzone_heartbeat", "name": "heartbeater", "checkout": "origin/release-20110331"}
      , {"repo": "dataset_manager", "checkout": "origin/release-20110331"}
      , {"repo": "cloud-analytics", "checkout": "origin/release-20110331", "target": "pkg", "tarball": "build/pkg/*.tar.gz", "output": ""}
      , {"repo": "zonetracker", "checkout": "origin/release-20110331"}
      , {"repo": "smart-login", "checkout": "origin/release-20110331"}
      ]
}
