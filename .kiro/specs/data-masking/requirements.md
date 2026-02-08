# 需求文档：数据脱敏功能

## 简介

数据脱敏功能使用户能够在将文件上传到云端 Dify 平台进行 AI 处理之前保护敏感信息。用户可以在本地桌面客户端对敏感数据进行脱敏处理，将脱敏后的文件存储在安全的沙箱环境中，上传到云端进行处理，并在返回结果时自动恢复原始数据。这确保了端到端的数据隐私，同时充分利用云端 AI 能力。

## 术语表

- **桌面客户端（Desktop_Client）**: 用户执行数据脱敏操作的本地桌面应用程序
- **脱敏引擎（Masking_Engine）**: 负责识别和替换敏感数据为脱敏值的组件
- **沙箱（Sandbox）**: 用户配置的本地目录，用于隔离和存储脱敏文件及脱敏元数据
- **脱敏规则（Masking_Rule）**: 用户定义的模式或配置，指定要脱敏的数据及脱敏方式
- **映射存储（Mapping_Store）**: 维护原始值与脱敏值之间关系的本地存储机制
- **云平台（Cloud_Platform）**: 使用 AI 模型处理脱敏文件的 Dify 云服务
- **反向替换（Reverse_Substitution）**: 在云端返回结果时恢复原始敏感数据的过程
- **脱敏文件（Masked_File）**: 敏感数据已被替换为脱敏值的文件
- **脱敏日志（Masking_Log）**: 存储在沙箱中的脱敏操作记录

## Requirements

### Requirement 1: Local Data Masking

**User Story:** As a user with sensitive data, I want to mask confidential information in my files locally, so that I can safely upload them to the cloud for AI processing without exposing private data.

#### Acceptance Criteria

1. WHEN a user selects a file for masking, THE Desktop_Client SHALL apply all active masking rules to identify sensitive data
2. WHEN sensitive data is identified, THE Masking_Engine SHALL replace it with masked values according to the masking rule configuration
3. WHEN masking is performed, THE Mapping_Store SHALL record the relationship between each original value and its masked replacement
4. WHEN a masking operation completes, THE Desktop_Client SHALL save the masked file to the user-configured sandbox path
5. THE Mapping_Store SHALL use a lightweight database or custom file storage format to maintain privacy and performance

### Requirement 2: Custom Masking Rules

**User Story:** As a user, I want to define custom masking rules for different types of sensitive data, so that I can control exactly what information is protected and how it is masked.

#### Acceptance Criteria

1. WHEN a user creates a masking rule, THE Desktop_Client SHALL allow specification of pattern matching criteria (regex, keywords, or data type)
2. WHEN a user creates a masking rule, THE Desktop_Client SHALL allow selection of masking strategy (replacement, tokenization, or format-preserving)
3. WHEN a user saves a masking rule, THE Desktop_Client SHALL validate the rule configuration and store it for future use
4. WHEN a user edits a masking rule, THE Desktop_Client SHALL update the rule configuration and apply changes to subsequent masking operations
5. WHEN a user deletes a masking rule, THE Desktop_Client SHALL remove it from active rules and prevent its use in future operations
6. THE Desktop_Client SHALL provide predefined rule templates for common sensitive data types (email, phone, credit card, SSN)

### Requirement 3: Sandbox Environment

**User Story:** As a user, I want to configure a local sandbox directory for storing masked files, so that my sensitive data processing is isolated and secure.

#### Acceptance Criteria

1. WHEN a user configures the sandbox path, THE Desktop_Client SHALL validate that the path exists and is writable
2. WHEN the sandbox path is set, THE Desktop_Client SHALL store this configuration persistently across application sessions
3. WHEN a user attempts to select a file for upload, THE Desktop_Client SHALL restrict file selection to only files within the configured sandbox path
4. WHEN masked files are created, THE Desktop_Client SHALL save them exclusively within the sandbox directory structure
5. WHEN masking logs are generated, THE Desktop_Client SHALL store them within the sandbox path
6. THE Desktop_Client SHALL prevent any file operations outside the sandbox boundary once configured

### Requirement 4: File Upload to Cloud

**User Story:** As a user, I want to upload masked files from my sandbox to the cloud platform, so that I can leverage AI processing capabilities without exposing my original sensitive data.

#### Acceptance Criteria

1. WHEN a user initiates file upload, THE Desktop_Client SHALL verify the file is located within the sandbox path before proceeding
2. WHEN uploading a masked file, THE Desktop_Client SHALL transmit only the masked version to the Cloud_Platform
3. WHEN the Cloud_Platform receives a file, THE Cloud_Platform SHALL process it with AI models without accessing the original data
4. WHEN file upload fails, THE Desktop_Client SHALL provide clear error messages and maintain the masked file in the sandbox
5. THE Desktop_Client SHALL track upload status and provide progress feedback to the user

### Requirement 5: Mapping Storage and Retrieval

**User Story:** As a user, I want the system to securely store the mapping between original and masked data, so that my sensitive information can be restored when results are returned.

#### Acceptance Criteria

1. WHEN a masking operation creates a mapping entry, THE Mapping_Store SHALL persist it with a unique identifier linking to the masked file
2. WHEN storing mapping data, THE Mapping_Store SHALL encrypt sensitive original values at rest
3. WHEN a masked file is uploaded, THE Desktop_Client SHALL associate the mapping identifier with the upload operation
4. WHEN retrieving mappings, THE Mapping_Store SHALL return only mappings associated with the specified file or operation
5. THE Mapping_Store SHALL support efficient lookup by masked value to enable reverse substitution
6. WHEN a masked file is deleted from the sandbox, THE Mapping_Store SHALL provide an option to delete associated mapping data

### Requirement 6: Reverse Substitution

**User Story:** As a user, I want the system to automatically restore my original sensitive data in results returned from the cloud, so that I can view complete and accurate information without manual intervention.

#### Acceptance Criteria

1. WHEN results are received from the Cloud_Platform, THE Desktop_Client SHALL identify all masked values in the response
2. WHEN a masked value is found, THE Desktop_Client SHALL query the Mapping_Store to retrieve the original value
3. WHEN the original value is retrieved, THE Desktop_Client SHALL replace the masked value with the original in the result
4. WHEN all substitutions are complete, THE Desktop_Client SHALL present the fully restored results to the user
5. IF a masked value has no corresponding mapping, THEN THE Desktop_Client SHALL log a warning and leave the masked value unchanged
6. THE Desktop_Client SHALL perform reverse substitution for all supported result formats (text, JSON, structured data)

### Requirement 7: Backend File Access Control

**User Story:** As a system administrator, I want the backend to only access files from user-configured sandbox paths, so that the system enforces security boundaries and prevents unauthorized file access.

#### Acceptance Criteria

1. WHEN the backend retrieves a file, THE Cloud_Platform SHALL verify the file path is within an authorized sandbox path
2. WHEN a file path is outside the sandbox, THE Cloud_Platform SHALL reject the request and return an authorization error
3. THE Cloud_Platform SHALL maintain a registry of authorized sandbox paths per user or session
4. WHEN processing file operations, THE Cloud_Platform SHALL validate all file paths against the sandbox registry before execution
5. THE Cloud_Platform SHALL log all file access attempts for security auditing

### Requirement 8: Data Masking Service API

**User Story:** As a developer, I want a dedicated data masking service with well-defined APIs, so that masking functionality can be integrated, maintained, and scaled independently.

#### Acceptance Criteria

1. THE Data_Masking_Service SHALL provide an API endpoint for applying masking rules to file content
2. THE Data_Masking_Service SHALL provide an API endpoint for managing masking rules (create, read, update, delete)
3. THE Data_Masking_Service SHALL provide an API endpoint for performing reverse substitution on result data
4. THE Data_Masking_Service SHALL provide an API endpoint for querying mapping data by file or operation identifier
5. WHEN an API request is received, THE Data_Masking_Service SHALL validate authentication and authorization before processing
6. WHEN an API operation fails, THE Data_Masking_Service SHALL return structured error responses with appropriate HTTP status codes

### Requirement 9: Security and Privacy

**User Story:** As a user concerned about data privacy, I want the masking system to protect my sensitive information throughout its lifecycle, so that my confidential data never leaves my control in unmasked form.

#### Acceptance Criteria

1. THE Mapping_Store SHALL encrypt all original sensitive values using industry-standard encryption (AES-256 or equivalent)
2. THE Desktop_Client SHALL never transmit original sensitive data to the Cloud_Platform
3. THE Desktop_Client SHALL store encryption keys securely using the operating system's credential management system
4. WHEN masking logs are created, THE Desktop_Client SHALL exclude original sensitive values from log entries
5. THE Desktop_Client SHALL provide an option to permanently delete mapping data and masked files from the sandbox
6. THE Desktop_Client SHALL clear sensitive data from memory immediately after masking or reverse substitution operations

### Requirement 10: User Interface and Experience

**User Story:** As a user, I want an intuitive interface for managing masking rules and sandbox configuration, so that I can easily protect my data without technical expertise.

#### Acceptance Criteria

1. WHEN a user opens the data masking interface, THE Desktop_Client SHALL display a clear overview of configured rules and sandbox status
2. WHEN a user creates or edits a masking rule, THE Desktop_Client SHALL provide a guided form with validation and preview capabilities
3. WHEN a user configures the sandbox path, THE Desktop_Client SHALL provide a directory picker and display the current configuration
4. WHEN masking operations are in progress, THE Desktop_Client SHALL display progress indicators and status messages
5. WHEN errors occur, THE Desktop_Client SHALL present user-friendly error messages with actionable guidance
6. THE Desktop_Client SHALL provide help documentation and tooltips explaining masking concepts and operations

### Requirement 11: Performance and Scalability

**User Story:** As a user working with large files, I want the masking system to process my data efficiently, so that I can complete my work without excessive delays.

#### Acceptance Criteria

1. WHEN masking a file under 10MB, THE Masking_Engine SHALL complete processing within 5 seconds
2. WHEN masking large files, THE Desktop_Client SHALL process data in streaming mode to avoid memory exhaustion
3. THE Mapping_Store SHALL support at least 100,000 mapping entries per file without performance degradation
4. WHEN performing reverse substitution, THE Desktop_Client SHALL complete processing within 2x the time of the original masking operation
5. THE Desktop_Client SHALL provide progress feedback for operations exceeding 3 seconds

### Requirement 12: Error Handling and Recovery

**User Story:** As a user, I want the system to handle errors gracefully and provide recovery options, so that I don't lose my work or data when problems occur.

#### Acceptance Criteria

1. WHEN a masking operation fails, THE Desktop_Client SHALL preserve the original file and provide an error report
2. WHEN mapping storage fails, THE Desktop_Client SHALL roll back the masking operation and notify the user
3. WHEN upload to the Cloud_Platform fails, THE Desktop_Client SHALL retain the masked file and mapping data for retry
4. WHEN reverse substitution encounters missing mappings, THE Desktop_Client SHALL complete partial substitution and report missing entries
5. THE Desktop_Client SHALL maintain operation logs to support troubleshooting and recovery
6. THE Desktop_Client SHALL provide a manual recovery option to restore system state after critical failures
