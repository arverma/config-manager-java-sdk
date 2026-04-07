# Publishing to Maven Central

This project uses Sonatype Central Portal with the `io.github.arverma` namespace. Coordinate changes and automation live in [`pom.xml`](pom.xml) and [`.github/workflows/publish-maven-central.yaml`](.github/workflows/publish-maven-central.yaml).

## Already done (outside this repo)

- [x] Central Portal account
- [x] Namespace **`io.github.arverma`** verified (GitHub-based proof)

## What you still need to do

### 1. User token (Maven Central — not GPG)

Central Portal issues a **username + password token pair** used by Maven to upload the bundle.

1. Sign in to [central.sonatype.com](https://central.sonatype.com/).
2. Open your profile / token area and **generate a user token** (follow the current UI labels; names vary).
3. Store the token as GitHub Actions secrets on **`config-manager-java-sdk`**:
   - `MAVEN_CENTRAL_USERNAME` — token **username** (identifier string from the portal)
   - `MAVEN_CENTRAL_PASSWORD` — token **password** (secret value)

These map to Maven `settings.xml` server id **`central`**, which matches `publishingServerId` in the POM.

### 2. GPG signing key (artifact signatures)

Maven Central requires **cryptographic signatures** on published artifacts. That is separate from the Central user token.

1. Create a GPG key pair (RSA 4096 is common).
2. Publish the **public** key to a keyserver the portal accepts (follow [Central signing docs](https://central.sonatype.org/publish/publish-gpg/)).
3. Add GitHub Actions secrets on **`config-manager-java-sdk`**:
   - `GPG_PRIVATE_KEY` — ASCII-armored **private** key (full block including `BEGIN/END`)
   - `GPG_PASSPHRASE` — passphrase for that key

The publish workflow uses `actions/setup-java` to import the key for `mvn -P release deploy`.

### 3. Cut a release (tag)

Versions are driven by the **`revision`** property (see [`pom.xml`](pom.xml)). Default local development is `0.1.0-SNAPSHOT`.

To publish a **release** artifact:

1. Ensure the OpenAPI sync and tests are in a good state on `main`.
2. Create and push an annotated or lightweight tag **`vX.Y.Z`** (example: `v0.1.0` → Maven version **`0.1.0`**).
3. GitHub Actions runs [`.github/workflows/publish-maven-central.yaml`](.github/workflows/publish-maven-central.yaml), which:
   - strips the `v` prefix for `-Drevision`
   - builds against `https://raw.githubusercontent.com/arverma/config-manager/main/api/openapi.yaml`
   - runs `mvn -B -P release clean deploy`

### 4. Confirm in Central Portal / search

After upload, the Central Portal validates the bundle. With `autoPublish` enabled in the POM, publishing may complete without a manual portal click (if your account and plugin settings allow it).

Find the artifact on Maven Central search, e.g.  
[search for `io.github.arverma config-manager-java-sdk`](https://central.sonatype.com/search?q=io.github.arverma+config-manager-java-sdk).

## Local dry run (optional)

With GPG configured locally:

```bash
mvn -P release clean verify
```

Full deploy requires Central credentials in `~/.m2/settings.xml` (server id `central`) and is usually done via CI.

## Troubleshooting

- **401 / auth failures**: Wrong token, expired token, or secrets not set on the SDK repo.
- **GPG failures in CI**: Key not armored correctly, wrong passphrase, or public key not published to a keyserver.
- **Version mismatch**: Tag must be `v` + SemVer; workflow passes `-Drevision` without `-SNAPSHOT` for releases.
