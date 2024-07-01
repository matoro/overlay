## matoro's gentoo overlay

My personal Gentoo overlay.  Contains some interesting apps/services and manual bumps of in-tree ebuilds.

You may be interested in:

* app-editors/tilde: "An intuitive text editor for the terminal"
* dev-db/opensearch: "Open source distributed and RESTful search engine" (binary distribution; NOT compiled from source)
* mail-mta/maddy: "Composable all-in-one mail server"
* net-analyzer/arkime: "Open source, large scale, full packet capturing, indexing, and database system" (requires pentoo overlay)
* net-misc/restool: "A user space application providing the ability to dynamically create and manage DPAA2 containers and objects from Linux"


#### uid/gid reference

| id    | name       | package                    |
|-------|------------|----------------------------|
| ~~19999~~ | ~~miniflux~~   | ~~www-apps/miniflux~~ ([added to `::gentoo` 2022.05.07](https://github.com/gentoo/gentoo/pull/25048))          |
| 19998 | maddy      | mail-mta/maddy             |
| 19997 | mattermost | www-apps/mattermost-server |
| ~~19996~~ | ~~synapse~~    | ~~net-im/synapse~~ ([added to `::gentoo` 2022.07.09](https://github.com/gentoo/gentoo/pull/25776))             |
| 19995 | opensearch | dev-db/opensearch          |
| 19994 | arkime     | net-analyzer/arkime        |
