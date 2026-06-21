# config-manager-java-sdk

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

Java client SDK for Config Manager, generated from the OpenAPI specification. The client uses the JDK 11+ `HttpClient` (**native** library) so the SDK stays lightweight and avoids extra HTTP client dependencies.

Published Maven coordinates: **`io.github.arverma:config-manager-java-sdk`** ([Maven Central search](https://central.sonatype.com/search?q=io.github.arverma+config-manager-java-sdk)).

**SDK semver is independent of Config Manager server releases.** See [`COMPATIBILITY.md`](COMPATIBILITY.md) for the API/SDK matrix and release process.

Generated code is placed under:

- `com.arverma.configmanager.client.api` — API classes (one per OpenAPI tag, e.g. `HealthApi`, `AuthApi`, `NamespacesApi`, `ConfigsApi`)
- `com.arverma.configmanager.client.model` — request/response models
- `com.arverma.configmanager.client.SdkCompatibility` — runtime metadata (SDK version, OpenAPI contract version, spec pin)

Models and APIs use standard Java collections (`java.util.List`, `java.util.Map`, etc.), which map cleanly to Scala via `scala.jdk.CollectionConverters` (Scala 2.13+) or `scala.collection.JavaConverters` (older Scala).

## Documentation (Medium)

Long-form guides for this SDK and its release pipeline:

- [OpenAPI to Maven Central: automate Java SDK client generation with GitHub Actions](https://medium.com/towards-data-engineering/openapi-to-maven-central-automate-java-sdk-client-generation-with-github-actions-8c3efcef3049) — separate API/SDK repos, OpenAPI Generator in Maven, generated code under `target/`, tag-triggered CI.
- [Publish a Java library to Maven Central with GitHub Actions (2026)](https://medium.com/p/2249800415f1) — verified namespace on Central, user token, GPG signing, `central-publishing-maven-plugin`, and troubleshooting (including keyserver propagation).

## Consume from Maven Central

After a release is published, add the dependency (no extra `<repository>` block is needed for Central):

**Maven**

```xml
<dependency>
  <groupId>io.github.arverma</groupId>
  <artifactId>config-manager-java-sdk</artifactId>
  <version>0.2.0</version>
</dependency>
```

**Gradle**

```kotlin
implementation("io.github.arverma:config-manager-java-sdk:0.2.0")
```

**sbt**

```scala
libraryDependencies += "io.github.arverma" % "config-manager-java-sdk" % "0.2.0"
```

Replace with the latest SDK version from [COMPATIBILITY.md](COMPATIBILITY.md) or Maven Central.

## OpenAPI input (development)

For local builds, this project expects the Config Manager repo as a **sibling directory** so the spec resolves at:

`../Config Manager/api/openapi.yaml`

If your layout differs, fetch the pinned spec or override the path:

```bash
bash .github/scripts/resolve-openapi-spec.sh openapi.yaml
mvn clean install -Dopenapi.spec.path=openapi.yaml
```

The pin is defined in [`openapi-compat.properties`](openapi-compat.properties) (also used by CI and publish).

## Build (local)

From this directory:

```bash
mvn clean install
```

That runs `openapi-generator-maven-plugin` in the `generate-sources` phase, then compiles the generated sources and installs the JAR to your local Maven repository. The POM uses the `revision` property (default `0.2.0-SNAPSHOT` for development).

## Initialize the client (Java)

```java
import com.arverma.configmanager.client.ApiClient;
import com.arverma.configmanager.client.api.HealthApi;
import com.arverma.configmanager.client.model.Healthz200Response;

public class Example {
  public static void main(String[] args) throws Exception {
    ApiClient client = new ApiClient(); // default base URI: http://localhost:8080
    client.updateBaseUri("http://localhost:8080"); // optional: set explicitly

    HealthApi health = new HealthApi(client);
    Healthz200Response live = health.healthz();
    System.out.println("ok = " + live.getOk());
  }
}
```

## Initialize the client (Scala)

```scala
import com.arverma.configmanager.client.ApiClient
import com.arverma.configmanager.client.api.HealthApi

object Example extends App {
  val client = new ApiClient()
  client.updateBaseUri("http://localhost:8080")

  val health = new HealthApi(client)
  val live = health.healthz()
  println(s"ok = ${live.getOk}")
}
```

When you read `List` or `Map` fields from models, convert in Scala with `import scala.jdk.CollectionConverters._` and `.asScala` on the Java collection.

## Authentication

When the Config Manager API has `auth.enabled=true`, protected routes require credentials. **Pipelines and services should use API keys**, not browser OAuth.

Set the `Authorization` header on every request via `ApiClient.setRequestInterceptor`:

```java
import com.arverma.configmanager.client.ApiClient;
import com.arverma.configmanager.client.api.NamespacesApi;

ApiClient client = new ApiClient();
client.updateBaseUri("https://config.example.com/api");
client.setRequestInterceptor(builder ->
    builder.header("Authorization", "Bearer cm_live_...")
);

NamespacesApi namespaces = new NamespacesApi(client);
namespaces.listNamespaces(null, null);
```

Create API keys with the upstream CLI (`config-manager auth create-api-key --name <name>`) or bootstrap via Helm secret `AUTH_API_KEYS`. Full setup: [Config Manager auth docs](https://github.com/arverma/config-manager/blob/main/docs/auth.md).

Browser Google OAuth and session cookies are for the web UI only; the SDK does not manage cookies.

## Compatibility

See [`COMPATIBILITY.md`](COMPATIBILITY.md) for the full API/SDK matrix and semver policy.

```java
import com.arverma.configmanager.client.SdkCompatibility;

// SDK artifact version (Maven)
SdkCompatibility.sdkVersion();

// OpenAPI contract this build was generated from
SdkCompatibility.openApiVersion();
SdkCompatibility.openApiSpecRef();
SdkCompatibility.minServerVersion();
```

Upstream [roadmap](https://github.com/arverma/config-manager/blob/main/docs/roadmap.md): RBAC v2 (viewer/developer roles) may add role-aware behavior later; API keys remain the integration path for machine clients.

## Runtime dependencies

Besides the JDK, this SDK expects Jackson (JSON) and related libraries on the classpath—the same dependencies declared in this project’s `pom.xml`. They are pulled in transitively when you depend on this artifact from Maven.

## Development and release

- **Local:** Regenerate and test with `mvn clean install` (or `mvn clean generate-sources test`) using a sibling checkout or `-Dopenapi.spec.path=...`. Generated sources live under `target/` (ignored by git).
- **CI:** Pull requests run [`.github/workflows/build.yaml`](.github/workflows/build.yaml) against the OpenAPI spec pinned in [`openapi-compat.properties`](openapi-compat.properties).
- **Release:** Push an SDK tag `vX.Y.Z` to run [`.github/workflows/publish-maven-central.yaml`](.github/workflows/publish-maven-central.yaml). The SDK version comes from the tag; the OpenAPI spec comes from the pin file—not from matching version numbers.

### Releasing after Config Manager API changes

Only required when [Config Manager `api/openapi.yaml`](https://github.com/arverma/config-manager/blob/main/api/openapi.yaml) changes in a client-visible way (new routes, models, security, etc.). Server-only changes do not need a new SDK.

1. Merge the OpenAPI change into Config Manager `main` and bump `info.version` when the contract changes.
2. Update [`openapi-compat.properties`](openapi-compat.properties): set `openapi.spec.ref` to a **commit SHA or server tag** (not `main` for releases), and `openapi.api.version` to match the spec.
3. Run `bash .github/scripts/resolve-openapi-spec.sh openapi.yaml && mvn clean install -Dopenapi.spec.path=openapi.yaml` and fix any compile issues.
4. Choose SDK semver from client-surface changes; add a row to [`COMPATIBILITY.md`](COMPATIBILITY.md).
5. Push tag `vX.Y.Z` on **this** repo.

Emergency override: set GitHub repo variable `OPENAPI_SPEC_URL` to a full raw spec URL.

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full license text. Project attribution is in [NOTICE](NOTICE).
