# STX GreenGrid

A decentralized renewable energy trading platform built on the Stacks blockchain, enabling peer-to-peer green energy transactions with transparent pricing and grid management.

## Overview

STX GreenGrid facilitates direct trading of renewable energy between producers and consumers through smart contracts. The platform creates a marketplace where renewable energy producers can sell excess capacity while consumers can purchase clean energy at competitive rates.

## Key Features

###  Energy Trading
- **Peer-to-Peer Transactions**: Direct energy trading between producers and consumers
- **Dynamic Pricing**: Market-driven tariff system with customizable pricing
- **Real-time Marketplace**: List and discover available energy capacity instantly

###  Grid Management
- **Capacity Monitoring**: Track total grid capacity and active power supply
- **Supply Balancing**: Automated grid supply management with capacity limits
- **Buyback System**: Grid operator can purchase excess energy at predetermined rates

###  Economic Model
- **Platform Fees**: Configurable fee structure for platform sustainability
- **Buyback Compensation**: Guaranteed compensation for excess energy production
- **Credit System**: Internal credit balancing for seamless transactions

###  Governance
- **Grid Operator Controls**: Administrative functions for tariff and rate management
- **Transparent Parameters**: Public access to all pricing and capacity information
- **Safety Mechanisms**: Built-in protections against invalid transactions

## Smart Contract Architecture

### Core Components

1. **Energy Marketplace**: Facilitates listing and trading of energy capacity
2. **Balance Management**: Tracks power and credit balances for all participants
3. **Grid Operations**: Manages total capacity and active supply
4. **Fee System**: Handles platform fees and buyback compensation

### Key Data Structures

- `producer-power-balance`: Tracks energy balance for each producer
- `consumer-credit-balance`: Manages STX credits for transactions
- `power-marketplace`: Lists available energy capacity with pricing

## Getting Started

### Prerequisites

- Stacks wallet (e.g., Hiro Wallet, Xverse)
- STX tokens for transactions
- Understanding of renewable energy trading concepts

### For Energy Producers

1. **Generate Energy**: Produce renewable energy (solar, wind, etc.)
2. **List Capacity**: Use `list-power-for-trading` to offer energy for sale
3. **Set Pricing**: Define your tariff per kWh
4. **Earn Credits**: Receive STX credits when consumers purchase your energy

### For Energy Consumers

1. **Load Credits**: Ensure sufficient credit balance for purchases
2. **Browse Marketplace**: Find available energy listings
3. **Purchase Power**: Use `purchase-power-from-producer` to buy energy
4. **Track Consumption**: Monitor your energy balance and usage

### For Grid Operators

1. **Deploy Contract**: Initialize the GreenGrid smart contract
2. **Set Parameters**: Configure tariffs, fees, and capacity limits
3. **Monitor Grid**: Track total capacity and active supply
4. **Manage Buybacks**: Purchase excess energy to balance the grid

## API Reference

### Public Functions

#### Trading Functions
```clarity
(list-power-for-trading (capacity uint) (tariff uint))
```
List energy capacity for trading in the marketplace.

```clarity
(purchase-power-from-producer (producer principal) (capacity uint))
```
Purchase energy from a specific producer.

```clarity
(buyback-power-to-grid (capacity uint))
```
Sell excess energy back to the grid operator.

#### Administrative Functions (Grid Operator Only)
```clarity
(set-green-tariff (new-tariff uint))
```
Set the base green energy tariff.

```clarity
(set-platform-fee-rate (new-rate uint))
```
Configure platform fee percentage (0-100%).

```clarity
(set-buyback-rate (new-rate uint))
```
Set buyback compensation rate (0-100%).

### Read-Only Functions

```clarity
(get-power-balance (producer principal))
```
Check energy balance for any participant.

```clarity
(get-credit-balance (consumer principal))
```
View STX credit balance for any user.

```clarity
(get-power-marketplace-listing (producer principal))
```
View marketplace listing for a producer.

## Economic Model

### Pricing Structure

- **Base Tariff**: Set by grid operator (default: 100 microstacks/kWh)
- **Producer Pricing**: Custom tariffs set by individual producers
- **Platform Fee**: Configurable percentage (default: 5%)
- **Buyback Rate**: Percentage of current tariff (default: 90%)

### Fee Distribution

1. **Energy Cost**: Paid directly to the producer
2. **Platform Fee**: Collected by grid operator for maintenance
3. **Buyback Compensation**: Paid by grid operator for excess energy

## Security Features

### Transaction Safety
- Self-trading prevention
- Insufficient balance checks
- Capacity validation
- Grid capacity limits

### Administrative Controls
- Operator-only functions for critical parameters
- Rate validation (0-100% for percentages)
- Positive value requirements for capacity and tariffs

## Deployment

### Contract Deployment
```bash
# Deploy to testnet
clarinet deployments apply -p deployments/testnet.yaml

# Deploy to mainnet
clarinet deployments apply -p deployments/mainnet.yaml
```

### Initial Configuration
After deployment, the grid operator should:
1. Set appropriate green tariff rates
2. Configure platform fee structure
3. Establish grid capacity limits
4. Fund operator account for buyback operations

## Contributing

We welcome contributions to improve STX GreenGrid! Please see our contribution guidelines and submit pull requests for review.

### Development Setup
```bash
git clone https://github.com/your-org/stx-greengrid
cd stx-greengrid
clarinet check
clarinet test
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions, bug reports, or feature requests, please open an issue on our GitHub repository.

## Roadmap

- [ ] Integration with IoT energy meters
- [ ] Mobile application for easy trading
- [ ] Advanced analytics dashboard
- [ ] Multi-token support (BTC, other assets)
- [ ] Automated market maker integration
- [ ] Carbon credit tokenization

---

**Build a sustainable future with decentralized renewable energy trading!**