{
    "release-name": "node-release"
  , "agents": [
      {"repo": "atropos", "checkout": "origin/develop"}
    , {"repo": "provisioner", "checkout": "origin/node-release"}
    , {"repo": "gzone_heartbeat", "name": "heartbeater", "checkout": "origin/node-release"}
    , {"repo": "dataset_manager", "checkout": "origin/develop"}
    , {"repo": "cloud-analytics", "checkout": "master", "target": "pkg", "tarball": "build/pkg/*.tar.gz", "output": ""}
  ]
}
