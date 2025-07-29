// Models for Typesense API

public struct APIStatsResponse: Codable, Sendable {
    public let delete_latency_ms: String
    public let delete_requests_per_second: String
    public let import_latency_ms: String
    public let import_requests_per_second: String
    public let latency_ms: [String: String]
    public let overloaded_requests_per_second: String
    public let pending_write_batches: String
    public let requests_per_second: [String: String]
    public let search_latency_ms: String
    public let search_requests_per_second: String
    public let total_requests_per_second: String
    public let write_latency_ms: String
    public let write_requests_per_second: String

    public init(
        delete_latency_ms: String,
        delete_requests_per_second: String,
        import_latency_ms: String,
        import_requests_per_second: String,
        latency_ms: [String: String],
        overloaded_requests_per_second: String,
        pending_write_batches: String,
        requests_per_second: [String: String],
        search_latency_ms: String,
        search_requests_per_second: String,
        total_requests_per_second: String,
        write_latency_ms: String,
        write_requests_per_second: String
    ) {
        self.delete_latency_ms = delete_latency_ms
        self.delete_requests_per_second = delete_requests_per_second
        self.import_latency_ms = import_latency_ms
        self.import_requests_per_second = import_requests_per_second
        self.latency_ms = latency_ms
        self.overloaded_requests_per_second = overloaded_requests_per_second
        self.pending_write_batches = pending_write_batches
        self.requests_per_second = requests_per_second
        self.search_latency_ms = search_latency_ms
        self.search_requests_per_second = search_requests_per_second
        self.total_requests_per_second = total_requests_per_second
        self.write_latency_ms = write_latency_ms
        self.write_requests_per_second = write_requests_per_second
    }
}

public struct AnalyticsEventCreateResponse: Codable, Sendable {
    public let ok: Bool
}

public struct AnalyticsEventCreateSchema: Codable, Sendable {
    public let data: [String: String]
    public let name: String
    public let type: String
}

public struct AnalyticsRuleDeleteResponse: Codable, Sendable {
    public let name: String
}

public struct AnalyticsRuleParameters: Codable, Sendable {
    public let destination: AnalyticsRuleParametersDestination
    public let expand_query: Bool
    public let limit: Int
    public let source: AnalyticsRuleParametersSource
}

public struct AnalyticsRuleParametersDestination: Codable, Sendable {
    public let collection: String
    public let counter_field: String
}

public struct AnalyticsRuleParametersSource: Codable, Sendable {
    public let collections: [String]
    public let events: [[String: String]]
}

public struct AnalyticsRuleUpsertSchema: Codable, Sendable {
    public let params: AnalyticsRuleParameters
    public let type: String
}

public struct AnalyticsRulesRetrieveSchema: Codable, Sendable {
    public let rules: [AnalyticsRuleSchema]
}

public struct ApiKeyDeleteResponse: Codable, Sendable {
    public let id: Int
}

public struct ApiKeySchema: Codable, Sendable {
    public let actions: [String]
    public let collections: [String]
    public let description: String
    public let expires_at: Int
    public let value: String
}

public struct ApiKeysResponse: Codable, Sendable {
    public let keys: [ApiKey]
}

public struct ApiResponse: Codable, Sendable {
    public let message: String
}

public struct CollectionAlias: Codable, Sendable {
    public let collection_name: String
    public let name: String
}

public struct CollectionAliasSchema: Codable, Sendable {
    public let collection_name: String
}

public struct CollectionAliasesResponse: Codable, Sendable {
    public let aliases: [CollectionAlias]
}

public struct CollectionSchema: Codable, Sendable {
    public let default_sorting_field: String
    public let enable_nested_fields: Bool
    public let fields: [Field]
    public let name: String
    public let symbols_to_index: [String]
    public let token_separators: [String]
    public let voice_query_model: VoiceQueryModelCollectionConfig
}

public struct CollectionUpdateSchema: Codable, Sendable, Equatable {
    public let name: String
    public let fields: [Field]

    public init(name: String, fields: [Field]) {
        self.name = name
        self.fields = fields
    }
}

public struct ConversationModelUpdateSchema: Codable, Sendable {
    public let account_id: String
    public let api_key: String
    public let history_collection: String
    public let id: String
    public let max_bytes: Int
    public let model_name: String
    public let system_prompt: String
    public let ttl: Int
    public let vllm_url: String
}

public enum DirtyValues: String, Codable, Sendable {
    case coerce_or_reject
    case coerce_or_drop
    case drop
    case reject
}

public enum DropTokensMode: String, Codable, Sendable {
    case right_to_left
    case left_to_right
    case both_sides_3 = "both_sides:3"
}

public struct FacetCounts: Codable, Sendable {
    public let counts: [[String: String]]
    public let field_name: String
    public let stats: [String: String]
}

public struct Field: Codable, Sendable, Equatable {
    public let drop: Bool
    public let embed: [String: String]
    public let facet: Bool
    public let index: Bool
    public let infix: Bool
    public let locale: String
    public let name: String
    public let num_dim: Int
    public let optional: Bool
    public let range_index: Bool
    public let reference: String
    public let sort: Bool
    public let stem: Bool
    public let stem_dictionary: String
    public let store: Bool
    public let symbols_to_index: [String]
    public let token_separators: [String]
    public let type: String
    public let vec_dist: String
}

public struct HealthStatus: Codable, Sendable {
    public let ok: Bool

    /// Public initializer so clients can construct sample values without decoding JSON.
    public init(ok: Bool) {
        self.ok = ok
    }
}

public enum IndexAction: String, Codable, Sendable {
    case create
    case update
    case upsert
    case emplace
}

public struct MultiSearchParameters: Codable, Sendable {
    public let cache_ttl: Int
    public let conversation: Bool
    public let conversation_id: String
    public let conversation_model_id: String
    public let drop_tokens_mode: DropTokensMode
    public let drop_tokens_threshold: Int
    public let enable_overrides: Bool
    public let enable_synonyms: Bool
    public let enable_typos_for_alpha_numerical_tokens: Bool
    public let enable_typos_for_numerical_tokens: Bool
    public let exclude_fields: String
    public let exhaustive_search: Bool
    public let facet_by: String
    public let facet_query: String
    public let facet_return_parent: String
    public let facet_strategy: String
    public let filter_by: String
    public let filter_curated_hits: Bool
    public let group_by: String
    public let group_limit: Int
    public let group_missing_values: Bool
    public let hidden_hits: String
    public let highlight_affix_num_tokens: Int
    public let highlight_end_tag: String
    public let highlight_fields: String
    public let highlight_full_fields: String
    public let highlight_start_tag: String
    public let include_fields: String
    public let infix: String
    public let limit: Int
    public let max_extra_prefix: Int
    public let max_extra_suffix: Int
    public let max_facet_values: Int
    public let min_len_1typo: Int
    public let min_len_2typo: Int
    public let num_typos: String
    public let offset: Int
    public let override_tags: String
    public let page: Int
    public let per_page: Int
    public let pinned_hits: String
    public let pre_segmented_query: Bool
    public let prefix: String
    public let preset: String
    public let prioritize_exact_match: Bool
    public let prioritize_num_matching_fields: Bool
    public let prioritize_token_position: Bool
    public let q: String
    public let query_by: String
    public let query_by_weights: String
    public let remote_embedding_num_tries: Int
    public let remote_embedding_timeout_ms: Int
    public let search_cutoff_ms: Int
    public let snippet_threshold: Int
    public let sort_by: String
    public let stopwords: String
    public let synonym_num_typos: Int
    public let synonym_prefix: Bool
    public let text_match_type: String
    public let typo_tokens_threshold: Int
    public let use_cache: Bool
    public let vector_query: String
    public let voice_query: String
}

public struct MultiSearchResult: Codable, Sendable {
    public let conversation: SearchResultConversation
    public let results: [MultiSearchResultItem]
}

public struct MultiSearchSearchesParameter: Codable, Sendable {
    public let searches: [MultiSearchCollectionParameters]
    public let union: Bool
}

public struct NLSearchModelBase: Codable, Sendable {
    public let access_token: String
    public let account_id: String
    public let api_key: String
    public let api_url: String
    public let api_version: String
    public let client_id: String
    public let client_secret: String
    public let max_bytes: Int
    public let max_output_tokens: Int
    public let model_name: String
    public let project_id: String
    public let refresh_token: String
    public let region: String
    public let stop_sequences: [String]
    public let system_prompt: String
    public let temperature: String
    public let top_k: Int
    public let top_p: String
}

public struct NLSearchModelDeleteSchema: Codable, Sendable {
    public let id: String
}

public struct PresetDeleteSchema: Codable, Sendable {
    public let name: String
}

public struct PresetsRetrieveSchema: Codable, Sendable {
    public let presets: [PresetSchema]
}

public struct SchemaChangeStatus: Codable, Sendable {
    public let altered_docs: Int
    public let collection: String
    public let validated_docs: Int
}

public struct SearchGroupedHit: Codable, Sendable {
    public let found: Int
    public let group_key: [String]
    public let hits: [SearchResultHit]
}

public struct SearchHighlight: Codable, Sendable {
    public let field: String
    public let indices: [Int]
    public let matched_tokens: [[String: String]]
    public let snippet: String
    public let snippets: [String]
    public let value: String
    public let values: [String]
}

public struct SearchOverrideDeleteResponse: Codable, Sendable {
    public let id: String
}

public struct SearchOverrideExclude: Codable, Sendable {
    public let id: String
}

public struct SearchOverrideInclude: Codable, Sendable {
    public let id: String
    public let position: Int
}

public struct SearchOverrideRule: Codable, Sendable {
    public let filter_by: String
    public let match: String
    public let query: String
    public let tags: [String]
}

public struct SearchOverrideSchema: Codable, Sendable {
    public let effective_from_ts: Int
    public let effective_to_ts: Int
    public let excludes: [SearchOverrideExclude]
    public let filter_by: String
    public let filter_curated_hits: Bool
    public let includes: [SearchOverrideInclude]
    public let metadata: [String: String]
    public let remove_matched_tokens: Bool
    public let replace_query: String
    public let rule: SearchOverrideRule
    public let sort_by: String
    public let stop_processing: Bool
}

public struct SearchOverridesResponse: Codable, Sendable {
    public let overrides: [SearchOverride]
}

public struct SearchParameters: Codable, Sendable {
    public let cache_ttl: Int
    public let conversation: Bool
    public let conversation_id: String
    public let conversation_model_id: String
    public let drop_tokens_mode: DropTokensMode
    public let drop_tokens_threshold: Int
    public let enable_highlight_v1: Bool
    public let enable_overrides: Bool
    public let enable_synonyms: Bool
    public let enable_typos_for_alpha_numerical_tokens: Bool
    public let enable_typos_for_numerical_tokens: Bool
    public let exclude_fields: String
    public let exhaustive_search: Bool
    public let facet_by: String
    public let facet_query: String
    public let facet_return_parent: String
    public let facet_strategy: String
    public let filter_by: String
    public let filter_curated_hits: Bool
    public let group_by: String
    public let group_limit: Int
    public let group_missing_values: Bool
    public let hidden_hits: String
    public let highlight_affix_num_tokens: Int
    public let highlight_end_tag: String
    public let highlight_fields: String
    public let highlight_full_fields: String
    public let highlight_start_tag: String
    public let include_fields: String
    public let infix: String
    public let limit: Int
    public let max_candidates: Int
    public let max_extra_prefix: Int
    public let max_extra_suffix: Int
    public let max_facet_values: Int
    public let max_filter_by_candidates: Int
    public let min_len_1typo: Int
    public let min_len_2typo: Int
    public let nl_model_id: String
    public let nl_query: Bool
    public let num_typos: String
    public let offset: Int
    public let override_tags: String
    public let page: Int
    public let per_page: Int
    public let pinned_hits: String
    public let pre_segmented_query: Bool
    public let prefix: String
    public let preset: String
    public let prioritize_exact_match: Bool
    public let prioritize_num_matching_fields: Bool
    public let prioritize_token_position: Bool
    public let q: String
    public let query_by: String
    public let query_by_weights: String
    public let remote_embedding_num_tries: Int
    public let remote_embedding_timeout_ms: Int
    public let search_cutoff_ms: Int
    public let snippet_threshold: Int
    public let sort_by: String
    public let split_join_tokens: String
    public let stopwords: String
    public let synonym_num_typos: Int
    public let synonym_prefix: Bool
    public let text_match_type: String
    public let typo_tokens_threshold: Int
    public let use_cache: Bool
    public let vector_query: String
    public let voice_query: String
}

public struct SearchResult: Codable, Sendable {
    public let conversation: SearchResultConversation
    public let facet_counts: [FacetCounts]
    public let found: Int
    public let found_docs: Int
    public let grouped_hits: [SearchGroupedHit]
    public let hits: [SearchResultHit]
    public let out_of: Int
    public let page: Int
    public let request_params: [String: String]
    public let search_cutoff: Bool
    public let search_time_ms: Int
}

public struct SearchResultConversation: Codable, Sendable {
    public let answer: String
    public let conversation_history: [[String: String]]
    public let conversation_id: String
    public let query: String
}

public struct SearchResultHit: Codable, Sendable {
    public let document: [String: [String: String]]
    public let geo_distance_meters: [String: Int]
    public let highlight: [String: String]
    public let highlights: [SearchHighlight]
    public let text_match: Int
    public let text_match_info: [String: String]
    public let vector_distance: String
}

public struct SearchSynonymDeleteResponse: Codable, Sendable {
    public let id: String
}

public struct SearchSynonymSchema: Codable, Sendable {
    public let locale: String
    public let root: String
    public let symbols_to_index: [String]
    public let synonyms: [String]
}

public struct SearchSynonymsResponse: Codable, Sendable {
    public let synonyms: [SearchSynonym]
}

public struct StemmingDictionary: Codable, Sendable {
    public let id: String
    public let words: [[String: String]]
}

public struct StopwordsSetRetrieveSchema: Codable, Sendable {
    public let stopwords: StopwordsSetSchema
}

public struct StopwordsSetSchema: Codable, Sendable {
    public let id: String
    public let locale: String
    public let stopwords: [String]
}

public struct StopwordsSetUpsertSchema: Codable, Sendable {
    public let locale: String
    public let stopwords: [String]
}

public struct StopwordsSetsRetrieveAllSchema: Codable, Sendable {
    public let stopwords: [StopwordsSetSchema]
}

public struct SuccessStatus: Codable, Sendable {
    public let success: Bool
}

public struct VoiceQueryModelCollectionConfig: Codable, Sendable {
    public let model_name: String
}

public typealias retrieveAllConversationModelsResponse = [ConversationModelSchema]

public typealias importStemmingDictionaryRequest = String

public typealias getSchemaChangesResponse = [SchemaChangeStatus]

public typealias retrieveMetricsResponse = [String: String]

public typealias retrieveAllNLSearchModelsResponse = [NLSearchModelSchema]

public typealias getCollectionsResponse = [CollectionResponse]

public struct debugResponse: Codable, Sendable {
    public let version: String
}

public typealias indexDocumentRequest = [String: String]

public struct deleteDocumentsResponse: Codable, Sendable {
    public let num_deleted: Int
}

public typealias getDocumentResponse = [String: String]

public typealias deleteDocumentResponse = [String: String]

public struct listStemmingDictionariesResponse: Codable, Sendable {
    public let dictionaries: [String]
}

public struct deleteStopwordsSetResponse: Codable, Sendable {
    public let id: String
}

// MARK: - Placeholder Schemas

public struct CollectionResponse: Codable, Sendable {
    public let name: String
}

public struct PresetSchema: Codable, Equatable, Sendable {
    public let id: String
    public let rules: [String]
}

public struct PresetUpsertSchema: Codable, Equatable, Sendable {
    public let rules: [String]
}
public struct AnalyticsRuleSchema: Codable, Sendable {}
public struct ApiKey: Codable, Sendable {}
public struct ConversationModelSchema: Codable, Sendable {}
public struct ConversationModelCreateSchema: Codable, Sendable {}
public struct MultiSearchCollectionParameters: Codable, Sendable {}
public struct MultiSearchResultItem: Codable, Sendable {}
public struct NLSearchModelSchema: Codable, Sendable {}
public struct NLSearchModelCreateSchema: Codable, Sendable {}
public struct NLSearchModelUpdateSchema: Codable, Sendable {}
public struct SearchOverride: Codable, Sendable {}
public struct SearchSynonym: Codable, Sendable {}
