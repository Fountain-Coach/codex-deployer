import Foundation

public enum OpenAPICuratorKit {
    public static var defaultSubmitter: (OpenAPI) -> Void = { _ in }

    public static func run(specs: [Spec],
                           rules: Rules = Rules(),
                           submit: Bool = false,
                           submitter: ((OpenAPI) -> Void)? = nil) -> (spec: OpenAPI, report: CuratorReport) {
        let result = curate(specs: specs, rules: rules)
        if submit {
            let handler = submitter ?? defaultSubmitter
            handler(result.spec)
        }
        return result
    }
}

