import Foundation

public enum OpenAPICuratorKit {
    public static func run(specs: [Spec], rules: Rules = Rules(), submit: Bool = false) -> (spec: OpenAPI, report: CuratorReport) {
        curate(specs: specs, rules: rules)
    }
}

