# LearningChoice

LearningChoice is a collaborative educational system for course content selection and academic standards built on the Stacks blockchain. It enables educators and institutions to collaboratively select course content, vote on academic standards, and manage educational resources through a transparent, decentralized governance model.

## Features

- **Educator Registration & Verification**: Secure registration system with institutional affiliation and verification process
- **Course Creation**: Verified educators can create courses with customizable voting requirements
- **Content Proposal System**: Democratic content submission and approval process
- **Collaborative Voting**: Transparent voting mechanism for content proposals
- **Academic Standards Management**: Community-driven academic standards development
- **Reputation System**: Track educator reputation and participation
- **Permission-based Access**: Role-based permissions ensuring only verified educators can participate

## Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity 2.0
- **Contract Version**: 1.0.0
- **Epoch**: 2.5
- **Test Framework**: Vitest with Clarinet SDK

## Installation

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) (v18 or higher)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd LearningChoice
```

2. Navigate to the contract directory:
```bash
cd LearningChoice_contract
```

3. Install dependencies:
```bash
npm install
```

4. Run tests:
```bash
npm test
```

5. Run tests with coverage:
```bash
npm run test:report
```

6. Watch mode for development:
```bash
npm run test:watch
```

## Usage Examples

### Register as an Educator

```clarity
(contract-call? .LearningChoice register-educator "University of Example")
```

### Create a Course

```clarity
(contract-call? .LearningChoice create-course
  "Introduction to Blockchain"
  "A comprehensive course covering blockchain fundamentals"
  u5  ;; required votes
  "undergraduate")
```

### Propose Content

```clarity
(contract-call? .LearningChoice propose-content
  u1  ;; course-id
  "Smart Contracts Basics"
  "An introductory module on smart contract development"
  "video")
```

### Vote on Content

```clarity
(contract-call? .LearningChoice vote-on-content
  u1    ;; content-id
  true) ;; vote (true for approval, false for rejection)
```

## Contract Functions Documentation

### Public Functions

#### `register-educator`
Registers a new educator with their institutional affiliation.
- **Parameters**: `institution` (string-ascii 100)
- **Returns**: `(response bool uint)`
- **Access**: Public

#### `verify-educator`
Verifies an educator (contract owner only).
- **Parameters**: `educator` (principal)
- **Returns**: `(response bool uint)`
- **Access**: Contract owner only

#### `create-course`
Creates a new course with specified parameters.
- **Parameters**:
  - `title` (string-ascii 100)
  - `description` (string-ascii 500)
  - `required-votes` (uint)
  - `academic-level` (string-ascii 50)
- **Returns**: `(response uint uint)`
- **Access**: Verified educators only

#### `propose-content`
Proposes new content for an existing course.
- **Parameters**:
  - `course-id` (uint)
  - `title` (string-ascii 100)
  - `description` (string-ascii 500)
  - `content-type` (string-ascii 50)
- **Returns**: `(response uint uint)`
- **Access**: Verified educators only

#### `vote-on-content`
Votes on a content proposal.
- **Parameters**:
  - `content-id` (uint)
  - `vote` (bool)
- **Returns**: `(response bool uint)`
- **Access**: Verified educators only

### Read-Only Functions

#### `is-verified-educator`
Checks if an educator is verified.
- **Parameters**: `educator` (principal)
- **Returns**: `bool`

#### `get-course`
Retrieves course information.
- **Parameters**: `course-id` (uint)
- **Returns**: `(optional course-data)`

#### `get-content-proposal`
Retrieves content proposal information.
- **Parameters**: `content-id` (uint)
- **Returns**: `(optional content-data)`

#### `get-educator`
Retrieves educator information.
- **Parameters**: `educator` (principal)
- **Returns**: `(optional educator-data)`

#### `has-voted`
Checks if a user has voted on specific content.
- **Parameters**: `voter` (principal), `content-id` (uint)
- **Returns**: `bool`

#### `get-vote`
Retrieves vote information.
- **Parameters**: `voter` (principal), `content-id` (uint)
- **Returns**: `(optional vote-data)`

## Data Structures

### Course
```clarity
{
  title: (string-ascii 100),
  description: (string-ascii 500),
  creator: principal,
  created-at: uint,
  is-active: bool,
  required-votes: uint,
  academic-level: (string-ascii 50)
}
```

### Content Proposal
```clarity
{
  course-id: uint,
  title: (string-ascii 100),
  description: (string-ascii 500),
  content-type: (string-ascii 50),
  proposer: principal,
  votes-for: uint,
  votes-against: uint,
  is-approved: bool,
  created-at: uint
}
```

### Educator
```clarity
{
  institution: (string-ascii 100),
  verified: bool,
  reputation-score: uint
}
```

## Error Codes

- `u100`: `ERR-NOT-AUTHORIZED` - User not authorized for this action
- `u101`: `ERR-COURSE-NOT-FOUND` - Specified course does not exist
- `u102`: `ERR-CONTENT-NOT-FOUND` - Specified content does not exist
- `u103`: `ERR-ALREADY-VOTED` - User has already voted on this content
- `u104`: `ERR-INVALID-VOTE` - Invalid vote format or value
- `u105`: `ERR-COURSE-ALREADY-EXISTS` - Course with this identifier already exists
- `u106`: `ERR-INSUFFICIENT-PERMISSIONS` - User lacks required permissions

## Deployment Guide

### Testnet Deployment

1. Configure Clarinet for testnet:
```bash
clarinet integrate
```

2. Deploy the contract:
```bash
clarinet deployments generate --testnet
clarinet deployments apply --testnet
```

### Mainnet Deployment

1. Ensure thorough testing on testnet
2. Configure mainnet settings in `settings/Mainnet.toml`
3. Deploy to mainnet:
```bash
clarinet deployments generate --mainnet
clarinet deployments apply --mainnet
```

## Security Notes

### Access Controls
- Only verified educators can create courses and propose content
- Contract owner has exclusive verification rights
- Voting is restricted to verified educators to prevent spam

### Governance Considerations
- Vote requirements are set per course to allow flexibility
- Double voting is prevented through vote tracking
- Content approval is automatic when vote threshold is reached

### Best Practices
- Verify educator credentials off-chain before on-chain verification
- Implement additional reputation mechanisms for enhanced trust
- Consider implementing time-based voting windows for proposals
- Regular audits of educator verification process recommended

### Known Limitations
- No built-in dispute resolution mechanism
- Content removal requires manual intervention
- Reputation scoring is basic and may need enhancement
- No financial incentives for participation

## Development

### Testing

The project includes comprehensive test suites using Vitest and Clarinet SDK:

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:report

# Watch mode for development
npm run test:watch
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the ISC License.

## Support

For questions, issues, or contributions, please refer to the project's issue tracker or contact the development team.