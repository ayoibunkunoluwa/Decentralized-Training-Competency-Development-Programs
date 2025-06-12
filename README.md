# Decentralized Training Competency Development Programs

A comprehensive blockchain-based system for managing training providers, competencies, learning paths, assessments, and certifications using Clarity smart contracts on the Stacks blockchain.

## Overview

This system provides a decentralized platform for:
- **Training Provider Verification**: Validates and manages training providers
- **Competency Mapping**: Defines and organizes competency frameworks
- **Learning Path Management**: Creates personalized learning journeys
- **Assessment Coordination**: Manages competency evaluations
- **Certification Tracking**: Issues and tracks competency certifications

## Smart Contracts

### 1. Training Provider Verification (`training-provider-verification.clar`)
Manages the registration, verification, and authorization of training providers.

**Key Features:**
- Provider registration with pending status
- Admin verification process
- Competency authorization for providers
- Provider suspension capabilities

**Main Functions:**
- `register-provider`: Register a new training provider
- `verify-provider`: Verify a registered provider (admin only)
- `authorize-competency`: Authorize provider for specific competencies
- `suspend-provider`: Suspend a provider's operations

### 2. Competency Mapping (`competency-mapping.clar`)
Defines competency frameworks with hierarchical relationships.

**Key Features:**
- Competency creation with levels (Beginner to Expert)
- Prerequisite management
- Skill mapping
- Competency relationships

**Main Functions:**
- `create-competency`: Define a new competency
- `add-competency-relationship`: Link related competencies
- `update-competency-level`: Modify competency difficulty level

### 3. Learning Path (`learning-path.clar`)
Manages personalized learning journeys for users.

**Key Features:**
- Custom learning path creation
- Milestone tracking
- Progress monitoring
- Path status management (Active, Completed, Paused)

**Main Functions:**
- `create-learning-path`: Create a personalized learning journey
- `complete-milestone`: Mark competency milestones as complete
- `pause-learning-path`: Pause an active learning path

### 4. Assessment Coordination (`assessment-coordination.clar`)
Coordinates competency assessments and evaluations.

**Key Features:**
- Assessment scheduling
- Multiple assessment types (Practical, Theoretical, Project, Peer Review)
- Assessor qualification management
- Scoring and feedback system

**Main Functions:**
- `schedule-assessment`: Schedule a competency assessment
- `start-assessment`: Begin an assessment session
- `complete-assessment`: Submit assessment results
- `qualify-assessor`: Authorize assessors for competencies

### 5. Certification Tracking (`certification-tracking.clar`)
Issues and manages competency certifications.

**Key Features:**
- Certification issuance with verification hashes
- Expiry date management
- Certification renewal process
- Revocation capabilities
- Multi-level certifications (Basic to Expert)

**Main Functions:**
- `issue-certification`: Issue a new certification
- `revoke-certification`: Revoke an existing certification
- `renew-certification`: Renew an expiring certification
- `verify-certification`: Verify certification authenticity

## Data Flow

1. **Provider Registration**: Training providers register and get verified
2. **Competency Definition**: Competencies are defined with levels and prerequisites
3. **Learning Path Creation**: Users create personalized learning paths
4. **Assessment Scheduling**: Qualified assessors schedule competency evaluations
5. **Certification Issuance**: Successful assessments lead to certification issuance

## Security Features

- **Role-based Access Control**: Different permissions for admins, providers, assessors, and learners
- **Verification Hashes**: Cryptographic verification for certifications
- **Expiry Management**: Time-bound certifications with renewal processes
- **Revocation System**: Ability to revoke compromised or invalid certifications

## Getting Started

### Prerequisites
- Stacks blockchain node
- Clarinet CLI tool
- Node.js and npm

### Installation

1. Clone the repository:
   \`\`\`bash
   git clone <repository-url>
   cd decentralized-training-system
   \`\`\`

2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

3. Deploy contracts:
   \`\`\`bash
   clarinet deploy
   \`\`\`

### Testing

Run the test suite:
\`\`\`bash
npm test
\`\`\`

## Usage Examples

### Register a Training Provider
\`\`\`clarity
(contract-call? .training-provider-verification register-provider
"TechCorp Training"
"Leading technology training provider"
"contact@techcorp.com")
\`\`\`

### Create a Competency
\`\`\`clarity
(contract-call? .competency-mapping create-competency
"JavaScript Programming"
"Fundamental JavaScript programming skills"
"Programming"
u2  ;; Intermediate level
(list)  ;; No prerequisites
(list "Variables" "Functions" "Objects" "Arrays"))
\`\`\`

### Schedule an Assessment
\`\`\`clarity
(contract-call? .assessment-coordination schedule-assessment
u1  ;; competency-id
'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7  ;; assessor
'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE  ;; candidate
u1  ;; practical assessment
u1000  ;; scheduled date
u100)  ;; max score
\`\`\`

## API Reference

Each contract provides read-only functions for querying data and public functions for state changes. Refer to individual contract files for detailed function signatures and parameters.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions and support, please open an issue in the GitHub repository.
