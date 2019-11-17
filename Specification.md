# Documentation Specification (2019-11-17)

This document specifies the format of LIKO-12's engine documentation.

## MarkDown links

Links in markdown files MUST BE relative links!
Except for media links (images and such), where it's possible to link to the media directory with `@MEDIA`, example: `![MyImage](@MEDIA/images/MyImage.png)`

## Common JSON Structures

This section descripts the structure of information in `.json` files.

### Types

The possible values for the `type` field in other structures:

- `string`: A simple type.
- `table`: Multiple possible types (simple or complex ones), (could contain a single type, but MUST NOT be empty).
- `"any"`: Any Lua type.
- `table`: A complex type, MUST exist in a table of types, it's a chain of directories names until the object directory is reached starting from the documentation root, example:

```js
[["Peripherals", "GPU", "objects","image"]]
```

#### Simple types

- `"number"`
- `"string"`
- `"boolean"`
- `"nil"`
- `"table"`
- `"userdata"`
- `"function"`

### Fields

```js
{
    "availableSince": [[1,0,0], [0,6,0]], // Category version, then LIKO-12 version
    "lastUpdatedIn": [[1,0,0], [0,8,0]], // Category version, then LIKO-12 version

    "shortDescription": "Short desc", // (Optional) Short description about the method. plain text and single line only!
    "longDescription": "Markdown and multiline supported", // (Optional) Long description about the method. Markdown and multiple lines are supported.

    "notes": [ // (Optional) Notes about the method. Markdown and multiple lines are supported.
        "Note #1",
        "Note #2",
        "..."
    ]

    "extra": "Markdown and multiple lines supported", // (Optional) Extra information about the method. Markdown and multiple lines are supported.

    "type": "number", // The type of the field, check the types structure section (It could be a string, array of strings, or array of arrays).

    "protected": false // (Optional, defaults to false) Whether if this field is protected from writing on (gives error when doing so) or not.
}
```

### Methods

Methods have 2 possible structures:

#### Single usage methods

```js
{
    "availableSince": [[1,0,0], [0,6,0]], // Category version, then LIKO-12 version
    "lastUpdatedIn": [[1,0,0], [0,8,0]], // Category version, then LIKO-12 version

    "shortDescription": "Short desc", // (Optional) Short description about the method. plain text and single line only!
    "longDescription": "Markdown and multiline supported", // (Optional) Long description about the method. Markdown and multiple lines are supported.

    "notes": [ // (Optional) Notes about the method. Markdown and multiple lines are supported.
        "Note #1",
        "Note #2",
        "..."
    ]

    "extra": "Markdown and multiple lines supported", // (Optional) Extra information about the method. Markdown and multiple lines are supported.

    "self": true, // (Optional, defaults to false, ONLY allowed in objects methods) Should ':' be used when calling this method.

    "arguments":[ // (Optional, MUST NOT be empty when specified).
        {
            "name": "the argument name", // (Optional when there is a "default" value) The name of the argument
            "type": "number", // The type of the value, check the types structure section (It could be a string, array of strings, or array of arrays).
            "description": "Single line description", // (Optional) Short description about the argument. Plain text and single line ONLY!

            "default": "nil" // (Optional) The default value when this argument is not specified.

            //An argument is optional when the default value is "nil".
            //An argument is required when "default" is ommited.
            //A literal argument is when the name is ommited and the default value is set.
            //An optional argument SHOULD NOT have "nil" in it's types.
            //A vararg argument would have the name "...".
        }
    ],

    "returns":[ // (Optional, MUST NOT be empty when specified).
        {
            "name": "return name", // The name of the return value. (Could be the value itself if it's a literal value, like "false", must be string).
            "type": "number", // The type of the value, check the types structure section (It could be a string, array of strings, or array of arrays).
            "description":"single line description" // (Optional) Short description about the return value. Plain text and single line ONLY!
        }
    ]
}
```

#### Multiple usage methods

```js
{
    //The following fields are inherted from the single usage variant.
    "availableSince": [[1,0,0], [0,6,0]],
    "lastUpdatedIn": [[1,0,0], [0,8,0]],
    "shortDescription": "Short desc",
    "longDescription": "Markdown and multiline supported",
    "notes": [
        "Note #1",
        "Note #2",
        "..."
    ]
    "extra": "Markdown and multiple lines supported",
    "self": true,

    "usages":[
        {

            "name": "Usage name", //The name of the usage variant.

            //The following fields are the same of the ones discribed before in this same code block.
            "shortDescription": "Short desc",
            "longDescription": "Markdown and multiline supported",
            "note": "A single line note, markdown supported",
            "notes": [
                "Note #1",
                "Note #2",
                "..."
            ]
            "extra": "Markdown and multiple lines supported",

            "arguments":[], //The arguments field is exactly like the single usage variant.
            "returns":[] //The returns field is exactly like the single usage variant.
        }
    ]
}
```

### Events

```js
{
    "availableSince": [[1,0,0], [0,6,0]], // Category version, then LIKO-12 version
    "lastUpdatedIn": [[1,0,0], [0,8,0]], // Category version, then LIKO-12 version

    "shortDescription": "Short desc", // (Optional) Short description about the method. plain text and single line only!
    "longDescription": "Markdown and multiline supported", // (Optional) Long description about the method. Markdown and multiple lines are supported.

    "notes": [ // (Optional) Notes about the method. Markdown and multiple lines are supported.
        "Note #1",
        "Note #2",
        "..."
    ]

    "extra": "Markdown and multiple lines supported", // (Optional) Extra information about the method. Markdown and multiple lines are supported.

    "arguments":[ // (Optional, MUST NOT be empty when specified).
        {
            "name": "return name", // The name of the event argument. (Could be the value itself if it's a literal value, like "false", must be string).
            "type": "number", // The type of the event argument, check the types structure section (It could be a string, array of strings, or array of arrays).
            "description":"single line description" // (Optional) Short description about the event argument. Plain text and single line ONLY!
        }
    ]
}
```

### Peripherals Meta

```js
{
    "version": [ 1,0,0 ], //The peripheral version.
    "availableSince": [ 0,6,0 ], // Available since LIKO-12 v0.6.0.
    "lastUpdatedIn": [ 0,8,0 ], // Last updated in LIKO-12 v0.8.0.
    "name": "Graphics Processing Unit", // (Optional) The full peripheral name.
    "shortDescription": "For drawing on the screen.", // Single line description. Plain text and single line ONLY!
    "fullDescription": "This peripheral allows you to draw at the screen\nwith much more advanced api." // (Optional) long description of the peripheral. Markdown and multiple lines are supported.
}
```

### Object Meta

```js
{
    "availableSince": [[1,0,0], [0,6,0]], // Category version, then LIKO-12 Version.
    "lastUpdatedIn": [[1,0,0], [0,8,0]], // Category version, then LIKO-12 Version.
    "shortDescription": "whatever", // (Optional) Short description. Plain text and single line ONLY!
    "fullDescription": "whatever", // (Optional) Long description. Markdown and multiple lines are supported.
    "notes": [ // (Optional) Notes about the method. Markdown and multiple lines are supported.
        "Note #1",
        "Note #2",
        "..."
    ],
    "extra": "Markdown and multiple lines supported" // (Optional) Extra information about the method. Markdown and multiple lines are supported.
}
```

### Documentation Meta

```js
{
    "engineVersion": [1,1,0], //The version of LIKO-12 being documented.
    "revisionDate": "2019-11-17", //The date of the documentation release, YYYY-MM-DD format.
    "revisionNumber": 0, //The number of the documentation release.
    "specificationDate": "2019-11-17", //The date of the specification implemented.
    "specificationLink": "https://github.com/LIKO-12/API-Documentation/blob/master/Specifications_Archive/2019-11-17-Specification.md" //A link to the specification implemented.
}
```

## Files structure

- `Engine_Documentation`: the root directory of the whole documentation.
  - `Engine_Documentation.json`: The `Documentation Meta` structure.
  - `Peripherals`: Peripherals documentation directory.
    - `PeripheralShortName`: (Optional) the documentation of a peripheral, considered a `category`.
      - `PeripheralShortName.json`: the `Peripherals Meta` structure of the peripheral.
        - `methods`: (Optional, MUST NOT exist when empty) the methods of the peripheral, contains `Methods` structures.
        - `objects`: (Optional, MUST NOT exist when empty) objects defined by the peripheral.
          - `ObjectName`: (Optional) the documented object.
            - `ObjectName.json`: The `Object Meta` structure.
            - `methods`: (Optional) The methods of the object.
            - `fields`: (Optional) The fields of the object.
            - `documents`: (Optional) Markdown documents about the object.
        - `events`: (Optional) Contains `Events` structures.
        - `documents`: (Optional) Markdown documents about the peripheral.
  - `Media`: This directory contains all the media files used in the markdown content.

## Changlog

### 2019/11/17

- Added a new seciton about links in markdown content.
- Added `specificationLink` to the documentation meta structure.
- Mark what folders are optional and what are not.
- Add the `Media` folder to the folders structures.

### 2019/11/16

- Remove the `"optional"` field in the return values of a method.
- The descriptions are now optional.
- The format of complex types has been changed.
- Removed the available for games field in peripherals meta, that should be contained on DiskOS's documentation side.
- Removed the `note` field, instead the `notes` field is now used all time.
- Specified a better files structure.
- New `Events`, `Fields` and `Documentation Meta` structures.

### 2018/??/?? (Unknown)

- Last specification without a changelog.
