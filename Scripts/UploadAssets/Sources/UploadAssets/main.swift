import Foundation
import Just
import ShellOut
import Rainbow
import Swime

let env = ProcessInfo.processInfo.environment
let repo = "LebJe/TestUploadAssets"

// Make sure we have a GitHub Token.
guard let ghToken = env["GH_TOKEN"] ?? env["GITHUB_TOKEN"] else {
	fputs("A GitHub OAuth Token is required to upload assets.".red, stderr)
	exit(1)
}

func getLatestReleaseID() -> Int {
	print("Getting latest release from \(repo)...")

	let res = Just.get(
		"https://api.github.com/repos/\(repo)/releases",
		headers: [
			"Authorization": "token \(ghToken)",
			"Accept": "application/vnd.github.v3+json"
		]
	)

	guard res.ok == true else {
		fputs(
			"Can't retrieve releases for \(repo). If this is a private repository, make sure the token you're using has access.\nFull error: \(String(data: res.content ?? Data(), encoding: .utf8) ?? "")".red,
			stderr
		)
		exit(2)
	}

	let decoder = JSONDecoder()
	decoder.dateDecodingStrategy = .iso8601

	guard let content = res.content,
		  let releases = try? decoder.decode(Releases.self, from: content),
		  releases.count >= 1 else {
		fputs("Unable to retrieve releases for \(repo). try creating a release, then rerun this program.".red, stderr)
		exit(3)
	}


	return releases[0].id
}

print("Building project...")
// TODO: build LFSPointers, then upload it.
guard let data = try? Data(contentsOf: URL(fileURLWithPath: "binary")) else {
	fputs("Missing Upload file".red, stderr)
	exit(4)
}

print("Uploading...")
// Upload the file.
let res = Just.post(
	"https://uploads.github.com/repos/LebJe/TestUploadAssets/releases/\(getLatestReleaseID())/assets?name=binary",
	headers: [
		"Authorization": "token \(ghToken)",
		"Content-Type": "\(Swime.mimeType(data: data)?.mime ?? "text/plain")",
		"Content-Length": "\(data.count)",
		"Accept": "application/vnd.github.v3+json"
	],
	requestBody: data
)

guard res.ok == true else {
	fputs("Unable to upload. Reason:\n\(String(data: res.content ?? Data(), encoding: .utf8) ?? "")".red, stderr)
	exit(4)
}

print("Result:\n\(String(data: res.content ?? Data(), encoding: .utf8) ?? "")")
