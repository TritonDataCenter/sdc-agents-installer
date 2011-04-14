{
    "release-name": "release-20110414"
  , "agents":
      [ {"repo": "atropos", "checkout": "origin/release-20110414"}
      , {"repo": "provisioner", "checkout": "origin/release-20110414"}
      , {"repo": "gzone_heartbeat", "name": "heartbeater", "checkout": "origin/release-20110414"}
      , {"repo": "dataset_manager", "checkout": "origin/release-20110414"}
      , {"repo": "cloud-analytics", "checkout": "origin/release-20110414", "target": "pkg", "tarball": "build/pkg/*.tar.gz", "output": ""}
      , {"repo": "zonetracker", "checkout": "origin/release-20110414"}
      , {"repo": "smart-login", "checkout": "origin/release-20110414"}
      ]
}
