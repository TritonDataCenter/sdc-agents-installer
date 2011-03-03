{
    "release-name": "develop"
  , "agents":
      [ {"repo": "atropos", "checkout": "origin/develop"}
      , {"repo": "provisioner", "checkout": "origin/develop"}
      , {"repo": "gzone_heartbeat", "name": "heartbeater", "checkout": "origin/develop"}
      , {"repo": "dataset_manager", "checkout": "origin/develop"}
      , {"repo": "cloud-analytics", "checkout": "master", "target": "pkg", "tarball": "build/pkg/*.tar.gz", "output": ""}
      , {"repo": "zonetracker", "checkout": "origin/develop"}
      ]
}
