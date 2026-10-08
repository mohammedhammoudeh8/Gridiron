# The Gridiron: NFL fan site with CI/CD

**Production:** https://mohammedhammoudeh.duckdns.org
**QA:** https://qa.mohammedhammoudeh.duckdns.org

IS373 Practical Test by Mohamad Hammoudeh. A simple static site served by nginx in a Docker container on my own DigitalOcean droplet, behind Traefik with Let's Encrypt HTTPS, deployed automatically with GitHub Actions.

## What's in this repo

| Path | What it is |
| --- | --- |
| `site/index.html` | The website source |
| `Dockerfile` | Builds the nginx image and stamps the commit SHA into the footer and `/version.txt` |
| `tests/validate.sh`, `tests/check_html.py` | Validation that runs before anything gets built or deployed |
| `deploy/compose.yaml` | Server config: Traefik, the `prod` container, and the `qa` container |
| `.github/workflows/deploy.yml` | The CI/CD pipeline |

## Branch and promotion rule

- Push to the **`qa`** branch → deploys to **QA** only (image tag `:qa`).
- Open a pull request from `qa` into **`main`**, check QA, then merge → deploys to **production** (image tag `:prod`).
- QA and production are separate containers with separate image tags, so a QA deploy never touches production until the change is merged into `main`.

## How the pipeline works

Any push to `qa` or `main` triggers the workflow. The first job validates the HTML (doctype, title, tags opened and closed correctly), builds the Docker image, runs it, and checks with curl that it serves the site and the right commit. If any of that fails, the workflow stops and nothing is pushed or deployed. If it passes, the second job builds the image with Docker Buildx and pushes it to Docker Hub tagged with the environment (`qa` or `prod`) and the short commit SHA. The third job connects to the droplet over SSH as my non-root user using a deploy key, copies `deploy/compose.yaml`, pulls the new image, and restarts only that environment's container. Traefik routes the main domain to `prod` and the `qa.` subdomain to `qa` over HTTPS. The last step checks the live site's `/version.txt` to confirm it's actually serving the new commit. Docker Hub and SSH credentials are stored in GitHub Actions secrets, never in the repo.

## Test Evidence

**Image registry:** https://hub.docker.com/r/mohammedhammoudeh/gridiron/tags

**Workflow runs**
- QA run (visible change): https://github.com/mohammedhammoudeh8/Gridiron/actions/runs/37846622203
- Production run (same change promoted): https://github.com/mohammedhammoudeh8/Gridiron/actions/runs/37846951516
- Deployed commit / image tag: `prod-a3229d2` (shown in the site footer and at `/version.txt`)

**Visible change, QA then production**

Changed the hero tag line on the `qa` branch, confirmed it on QA while production still showed the old version, then merged `qa` into `main`.

| Step | Screenshot |
| --- | --- |
| QA updated, production unchanged | ![QA](evidence/qa-updated.png) ![Prod before](evidence/prod-before.png) |
| Production after merge | ![Prod after](evidence/prod-after.png) |

**SSH security** (no keys, passwords, or tokens shown)

| Check | Screenshot |
| --- | --- |
| SSH-key login as non-root user `mohamad`, with sudo | ![ssh login](evidence/ssh-login.png) |
| Effective settings: `permitrootlogin no`, `passwordauthentication no` | ![sshd -T](evidence/sshd-settings.png) |
| Root login and password login rejected | ![rejected](evidence/ssh-rejected.png) |
