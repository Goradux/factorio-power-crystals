// # # 1. read the version in the json
// # # 2. zip and rename
// # # 3. move to mod folder

// # with open("./PowerCrystals/info.json", "r") as f:
// #     data = f.read()
// #     data.

import JSZip from "jszip";

const zip = new JSZip();

const img = zip.folder("images");
