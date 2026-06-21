# API / SDK compatibility

Config Manager **server releases** and the **Java SDK** use **independent semver**. The SDK declares which OpenAPI contract it was generated from; consumers pick an SDK version, not a matching server tag.

Runtime metadata is available in code:

```java
import com.arverma.configmanager.client.SdkCompatibility;

SdkCompatibility.sdkVersion();        // e.g. "0.2.0" — Maven artifact version
SdkCompatibility.openApiVersion();    // e.g. "0.2.0" — OpenAPI info.version
SdkCompatibility.openApiSpecRef();    // git ref used at codegen time
SdkCompatibility.minServerVersion();  // lowest tested server version
```

## Compatibility matrix

| SDK version | OpenAPI `info.version` | Spec pin (`openapi-compat.properties`) | Min Config Manager server |
|-------------|------------------------|----------------------------------------|-----------------------------|
| 0.1.0       | 0.1.0                  | `v0.1.0` on `arverma/config-manager`   | 0.1.0                       |
| 0.2.0       | 0.2.0                  | `main` (replace with commit SHA when tagging) | 0.1.0                       |

Server patch releases within the same OpenAPI contract generally work without a new SDK. Regenerate and release a new SDK when `api/openapi.yaml` changes in a client-visible way (new routes, models, auth, breaking renames).

## Pinning the OpenAPI spec

[`openapi-compat.properties`](openapi-compat.properties) is the single source of truth for CI and publish:

| Property | Meaning |
|----------|---------|
| `openapi.spec.repo` | GitHub repo containing `api/openapi.yaml` |
| `openapi.spec.ref` | Tag, branch, or **commit SHA** (prefer SHA or tag for reproducible builds) |
| `openapi.api.version` | Expected `info.version` in the pinned spec (validated at CI with a warning on mismatch) |
| `server.version.min` | Documented minimum server version |

Emergency override: set GitHub repo variable `OPENAPI_SPEC_URL` to a full raw spec URL.

## Releasing a new SDK version

1. Merge OpenAPI changes into [config-manager](https://github.com/arverma/config-manager) and bump `info.version` in `api/openapi.yaml` when the contract changes.
2. Tag the **server** release if you ship one (optional; independent of SDK semver).
3. Update `openapi-compat.properties` with the new spec ref and `openapi.api.version`.
4. Run `bash .github/scripts/resolve-openapi-spec.sh openapi.yaml && mvn clean install -Dopenapi.spec.path=openapi.yaml`.
5. Choose SDK semver from **client surface** changes (major = breaking, minor = additive, patch = regen/docs).
6. Add a row to the matrix above and push SDK tag `vX.Y.Z`.

SDK and API version numbers do **not** need to match.
