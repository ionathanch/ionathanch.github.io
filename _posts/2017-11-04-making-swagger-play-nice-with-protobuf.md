---
layout: post
title: "Making Swagger play nice with ProtoBufs"
excerpt_separator: "<!--more-->"
tags:
  - Swagger
  - ProtoBuf
  - Scala
  - Play Framework
---

My previous workplace's frontend is mostly in TypeScript and the backend mostly in Scala, and to share data back and forth, DTOs written as ProtoBufs were implemented some time ago. There’s a script that generates from these ProtoBuf files Java classes using [protobuf-java](https://github.com/google/protobuf/tree/master/java) and TypeScript classes using [protobufjs](https://www.npmjs.com/package/protobufjs). The Java classes can then be used directly in Scala code.

<!--more-->

The problem with this is that the generated Java classes have a lot of complex and extraneous structure, with static methods, builders, accessors, etc. Compare that to some of our Scala DTOs, which may simply look like this:

```scala
case class AddressBookDTO(owner: PersonDTO, contacts: Seq[PersonDTO])
```

When [Swagger](https://github.com/swagger-api/swagger-play/tree/master/play-2.6/swagger-play2) translates these DTOs to Swagger definitions, Scala case classes will transform nicely, but the extraneous structure from the generated Java classes will remain in the Swagger JSON documentation and pollute the actual structure we want to see. Since we need to maintain interoperability with legacy Java code, instead of using [ScalaPB](https://scalapb.github.io/) to generate Scala code from ProtoBuf, I had to directly convert ProtoBuf into Swagger’s JSON format. This also had the benefit of being able to see breaking changes in all of our DTOs when Swagger JSON files are compared.

The first step was to collect all the ProtoBuf code into a single file. I’m sure there exist ProtoBuf parsers in Python that allow you to manipulate messages and services as object, but ProtoBuf files are simple enough that I simply went through all of the files (using the lovely `os.walk`) line by line and appended them all to the output file. There were, however, four problems encountered:

* **Message name collision**. This was fairly easy to solve: append each message name with the package name, using underscores `_` in lieu of periods `.` to satisfy the proto3 syntax.
Note that messages with the same name in the same package can occur in different files, which can cause the same problems. These are circumvented in the Java generated classes because the all messages in one file are wrapped in an outer class named after the filename, but if we want to merge all the ProtoBuf files we must ensure these collisions don’t exist first to avoid having to append the filename too.
    
* **Enumeration value name collision**. According to `protoc`, enum values don’t belong to the message they’re contained in, but are rather global to the file. This was similarly solved by appending the package name to the enum value name, which is stylistically uglier but functional.
* Lack of services. When messages aren’t being used by a service, they aren’t converted at all, so for each message in the output file a dummy service was added: 
```service DummyService { rpc Dummy (MyDTO) returns (MyDTO); }```

* **Comment conversion**. Whole-line comments would appear in the Swagger definitions in unusual places, causing parsing errors later on, so they were removed. Post-line comments seemed to be fine, and luckily we didn’t have any multi-line comments to parse.

Next was generating the Swagger JSON file from the agglomerated ProtoBuf file using [`protoc`](https://github.com/grpc-ecosystem/grpc-gateway):

```bash
$ go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger
$ protoc \
    --plugin=protoc-gen-swagger=$GOPATH/bin/protoc-gen-swagger \
    --swagger_out=logtostderr=true:. \
    all_protobuf.proto
$ sed -i "s _ \. g" all_protobuf.swagger.json
```

`protoc` will output a `.swagger.json` file, and I also replaced all underscores with periods in the JSON for legibility using `sed` in-place with space delimeters.

Finally, [Swagger annotations](https://mvnrepository.com/artifact/io.swagger/swagger-annotations) come into play. The `@ApiAnnotation` annotation has a handy `responseReference` field that allows you define the response type by referring to a definition it assumes to already exist somewhere in the file:

```scala
@ApiOperation(value = "", responseReference = "io.nonphatic.TheDTO")
```

However, the `@ApiImplicitParam` has no equivalent field (contrary to what [this](https://github.com/swagger-api/swagger-core/issues/864#issuecomment-99580005) says), which means some post-generation manipulation will need to be done. The requests are added with these fields instead:

```scala
@ApiImplicitParams(Array(
    new ApiImplicitParam(
        paramType = "form", 
        name = "io.nonphatic.firstRequestDTO"),
    new ApiImplicitParam(
        paramType = "form", 
        name = "io.nonphatic.secondRequestDTO")
))
```

Since the `form` parameter type isn’t legitimately used elsewhere, it serves as a handy identifier for which parameters need to be modified. Using [swagger-models](https://mvnrepository.com/artifact/io.swagger/swagger-models), converting a `form` parameter to a `body` parameter (the only one that will show you the request object’s structure in SwaggerUI and ReDoc) and the `form.name` field to a `body.schema.ref` field with the other fields unchanged is fairly straightforward. This can be done in a custom controller that extends Swagger’s `ApiHelperController` and overrides the `getResources` method. As a final step, [swagger-parser](https://mvnrepository.com/artifact/io.swagger/swagger-parser) can be used to parse the ProtoBuf definitions Swagger JSON file into a Swagger object, and the definitions can be merged into the final Swagger JSON response.

### Addendum

The Swagger JSON documentation is only generated from the annotations on runtime. Since we needed to access the documentation in TeamCity without running the full server, I added a unit test that uses ScalaTest’s [OneServerPerTest](https://www.playframework.com/documentation/2.6.x/ScalaFunctionalTestingWithScalaTest#testing-with-a-server) trait, where I could inject the custom Swagger controller and use its `getResources` method to write the JSON into a file. Then only a unit test needs to be run rather than the server.
