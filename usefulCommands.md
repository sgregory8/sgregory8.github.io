---
layout: page
title: Useful Commands
permalink: /usefulCommands/
---

Some commands I find useful...

## Maven

Describes plugin goals and what phase the plugin is bound to

```bash
mvn help:describe -DgroupId=<pluginGroupId> \
                  -DartifactId=<pluginArtifactId> \
                  -Ddetail=true
```
