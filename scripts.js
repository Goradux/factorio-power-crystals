import AdmZip from "adm-zip";
import * as fs from "fs";
import info from "./mod/PowerCrystals/info.json" assert { type: "json" };
import env from "./env.json" assert { type: "json" };

async function createZipArchive() {
  const zip = new AdmZip();
  const version = info.version;
  const outputFilename = `PowerCrystals_${version}.zip`;
  zip.addLocalFolder("./mod");
  zip.writeZip(outputFilename);
  console.log(`Created ${outputFilename} successfully`);
  return outputFilename;
}

const filename = await createZipArchive();

var newPath = env.modFolderPath + filename;

fs.rename(filename, newPath, function (err) {
  if (err) throw err;
  console.log("Successfully moved the mod to mod folder. Ready to debug.");
});
