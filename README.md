# LIKO-12-API

## Generating Docs

### Preperation

1. Move docscripts.lua into D:/OS.
2. Move the other scripts into D:/Programs.
3. Move documentation into D:/JSON_Source.

### Usage

* Run verify to make sure the docs are well made.
* Run analyze to learn more about the docs.
* Run generate to create the docs

## Spec:

### Value Types:
* string: A simple type.
* table: A collection of types.
* "any": Any type.
* table: This has to exist in a collection of types, the collection could contain only one.

```js
["Peripherals","GPU","image"] //This type references to a format/object of the GPU peripheral, with the name "image"
```

#### Default types:

* "number"
* "string"
* "boolean"
* "nil"
* "table"
* "userdata"
* "function"

### Folder Structure:

```
└───Peripherals
    ├───CPU
    │   └...
    ├───GPU
    │   ├───formats
    │   │   └───string
    │   │       └───...
    │   ├───methods
    │   │   └───...
    │   └───objects
    │       ├───imageData
    │       │   └───methods
    │       │       └───...
    │       └───...
    └...
```

### Peripheral Info Json:

* Located in the root of the peripheral api folder.
* Has the name: `folderName.json`

```js
{
	"availableForGames": true, //Is the peripheral available for games.
	"version": [ 1,0,0 ], //The peripheral version.
	"availableSince": [ 0,6,0 ], //Available since LIKO-12 v0.6.0.
	"lastUpdatedIn": [ 0,8,0 ], //Last updated in LIKO-12 v0.8.0.
	"name": "Graphics Processing Unit", //The full peripheral name, Optional.
	"shortDescription": "For drawing on the screen.", //Single line description.
	"fullDescription": "This peripheral allows you to draw at the screen\nwith much more advanced api." //Markdown supported, optional.
}
```

### Object Info Json:

* Located in the root of the object api folder.
* Has the name: `folderName.json`

```js
{
	"availableSince": [[1,0,0], [0,6,0]], // GPU Version, then LIKO-12 Version
	"lastUpdatedIn": [[1,0,0], [0,8,0]], //The same
	"shortDescription": "whatever", //Single line description.
	"fullDescription": "whatever", //Markdown supported, optional.
	"note": "A single line note, markdown supported", //Shouldn't exist if "notes" exists.
	"notes": [ //Multiple notes if needed.
		"Note #1",
		"Note #2",
		"..."
	],
	"extra": "Markdown and multiple lines supported" //Extra information, (Optional).
}
```

### Method Json:

* Located in `Peripheral/Methods/methodName.JSON` or `Peripheral/objects/methods/methodName.json`

```js
//Single usage variant.
{
	"availableSince": [[1,0,0], [0,6,0]], // GPU Version, then LIKO-12 Version
	"lastUpdatedIn": [[1,0,0],[0,8,0]], //The same.
	"shortDescription": "Short desc",
	"longDescription": "Markdown and multiline supported", //Optional
	"note": "A single line note, markdown supported", //Shouldn't exist if "notes" exists.
	"notes": [ //Multiple notes if needed.
		"Note #1",
		"Note #2",
		"..."
	]
	"extra": "Markdown and multiple lines supported", //Extra information, (Optional).
	"self": true, //Should the user use ':' when calling this method (Objects only).
	"arguments":[ //Shouldn't exists when there are no arguments
		{
			//If the name was not provided, and the argument has a default value, then it's a constant value.
			//The name can be "..." for varavg.
			"name": "the argument name",
			"type": "number", //Check the value types section.
			"description": "Single line description", //Optional when name is null.
			"default": "nil"
			//This specified means that this argument is optional, and so do not specify "nil" in the supported types.
			//If there is no default value, but this argument is optional, then specify "default": "nil".
		}
	],
	"returns":[ //Shouldn't exists when there are not returns
		{
			"name":"return name", //can be "..."
			"type": "number", //Check the value types section.
			"optional": true, //Please don't add nil to the types.
			"description":"single line description"
		}
	]
}
```

```js
//Multi usages variant.
{
	"availableSince": [[1,0,0], [0,6,0]], // GPU Version, then LIKO-12 Version
	"lastUpdatedIn": [[1,0,0],[0,8,0]], //The same.
	"shortDescription": "Short desc",
	"longDescription": "Markdown and multiline supported", //Optional
	"note": "A single line note, markdown supported", //Shouldn't exist if "notes" exists.
	"notes": [ //Multiple notes if needed.
		"Note #1",
		"Note #2",
		"..."
	]
	"extra": "Markdown and multiple lines supported", //Extra information, (Optional).
  "self": true, //Should the user use ':' when calling this method (Objects only).
  "usages":[
    {
      "name": "Usage name",
      "shortDescription": "Short desc",
      "longDescription": "Markdown and multiline supported", //Optional
      "note": "A single line note, markdown supported", //Shouldn't exist if "notes" exists.
      "notes": [ //Multiple notes if needed.
        "Note #1",
        "Note #2",
        "..."
      ]
      "extra": "Markdown and multiple lines supported", //Extra information, (Optional).
      "arguments":[ //Shouldn't exists when there are no arguments
        {
          //If the name was not provided, and the argument has a default value, then it's a constant value.
          //The name can be "..." for vararg.
          "name": "the argument name",
          "type": "number", //Check the value types section.
          "description": "Single line description", //optional when name is null
          "default": "nil"
          //This specified means that this argument is optional, and so do not specify "nil" in the supported types.
          //If there is no default value, but this argument is optional, then specify "default": "nil".
        }
      ],
      "returns":[ //Shouldn't exists when there are not returns
        {
          "name":"return name", //can be "..."
          "type": "number", //Check the value types section.
          "optional": true, //Please don't add nil to the types.
          "description":"single line description"
        }
      ]
    },
    {
      //Another usage.
    }
  ]
}
```

## OldSpec:

### API Functions:

**Note:** The function name is determined from the file name.

#### Single usage

```json
{
  "desc":"Function desction, starts with big letter, and ends with a .\n\nLonger description",
  "note":"A note, optional, shouldn't be used when 'notes' is used",
  "notes":[
    "Accepts multiple notes.",
    "Note #2."
  ],
  "args":[
    {
      "name":"Arg 1 name",
      "type":"number",
      "desc":"Number, string, boolean, nil, any [CHOOSE ONE]"
    },
    {
      "name":"...",
      "type":["number","nil"],
      "desc":"Vararg"
    },
    {
      "name":"Optional arg",
      "type":["number","nil"],
      "default":"0",
      "desc":"Optional arg description."
    }
  ],
  "rets":[
    {
      "name":"Ret 1.",
      "type":"",
      "desc":""
    }
  ]
}
```

#### Multi usage

```json
{
  "desc":"Overall description.",
  "Usage":[
    {
      "name":"First usage:",
      "desc":"It may have a description",
      "args":[],
      "rets":[]
    },
    {
      "name":"Second usage:",
      "desc":"It may have a description",
      "args":[],
      "rets":[]
    }
  ]
}
```

**Note:** `args` and `rets` can be null.

## Event function:

**Note:** The function name is determined from the file name.

```json
{
  "desc":"desc",
  "note":"",
  "notes":["",""],
  "args":[
    {
      "name":"",
      "type":"",
      "desc":""
    }
  ]
}
```
