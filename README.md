# config-manager-java-sdk

Java client SDK for Config Manager, generated from the OpenAPI specification. The client uses the JDK 11+ `HttpClient` (**native** library) so the SDK stays lightweight and avoids extra HTTP client dependencies.

Published Maven coordinates: **`io.github.arverma:config-manager-java-sdk`** ([Maven Central search](https://central.sonatype.com/search?q=io.github.arverma+config-manager-java-sdk)).

Generated code is placed under:

- `com.arverma.configmanager.client.api` — API classes (one per OpenAPI tag, e.g. `HealthApi`, `NamespacesApi`, `ConfigsApi`)
- `com.arverma.configmanager.client.model` — request/response models

Models and APIs use standard Java collections (`java.util.List`, `java.util.Map`, etc.), which map cleanly to Scala via `scala.jdk.CollectionConverters` (Scala 2.13+) or `scala.collection.JavaConverters` (older Scala).

## Consume from Maven Central

After a release is published, add the dependency (no extra `<repository>` block is needed for Central):

**Maven**

```xml
<dependency>
  <groupId>io.github.arverma</groupId>
  <artifactId>config-manager-java-sdk</artifactId>
  <version>0.1.0</version>
</dependency>
```

**Gradle**

```kotlin
implementation("io.github.arverma:config-manager-java-sdk:0.1.0")
```

**sbt**

```scala
libraryDependencies += "io.github.arverma" % "config-manager-java-sdk" % "0.1.0"
```

Replace `0.1.0` with the latest release version. Publishing from maintainers is documented in [`PUBLISHING.md`](PUBLISHING.md).

## OpenAPI input (development)

For local builds, this project expects the Config Manager repo as a **sibling directory** so the spec resolves at:

`../Config Manager/api/openapi.yaml`

If your layout differs, override the path when building:

```bash
mvn clean install -Dopenapi.spec.path=/absolute/path/to/openapi.yaml
```

CI workflows use the published spec on GitHub (`arverma/config-manager`) instead of a sibling path.

## Build (local)

From this directory:

```bash
mvn clean install
```

That runs `openapi-generator-maven-plugin` in the `generate-sources` phase, then compiles the generated sources and installs the JAR to your local Maven repository. The POM uses the `revision` property (default `0.1.0-SNAPSHOT` for development).

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

## Runtime dependencies

Besides the JDK, this SDK expects Jackson (JSON) and related libraries on the classpath—the same dependencies declared in this project’s `pom.xml`. They are pulled in transitively when you depend on this artifact from Maven.

## CI/CD

### OpenAPI sync (manual)

- Run `Sync SDK From Config Manager OpenAPI` from GitHub Actions when you want to regenerate the client and open a PR.
- Inputs: `source_ref` (default `main`), optional `source_sha` to pin a commit.
- The OpenAPI spec is fetched from `arverma/config-manager` on GitHub. To use another fork, change `CONFIG_MANAGER_REPO` in `.github/workflows/sync-openapi-sdk.yaml`.

### Maven Central release (tag)

- Push a tag `vX.Y.Z` to run `.github/workflows/publish-maven-central.yaml` and deploy to Central. See [`PUBLISHING.md`](PUBLISHING.md) for secrets and one-time setup.
