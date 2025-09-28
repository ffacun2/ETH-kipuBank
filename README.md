# KipuBank 🏦

## Descripción del Contrato

**KipuBank** es un contrato inteligente de bóveda bancaria descentralizada implementado en la blockchain de Ethereum. Está diseñado para gestionar depósitos y retiros de **Ether (ETH)** de forma segura, imponiendo límites estrictos para proteger tanto a los usuarios como a la integridad del banco.

### Características Clave

* **Deposito Personal:** Cada usuario tiene un saldo individual y privado.
* **Límite Global (`i_limitBancario`):** Se establece una capacidad máxima de ETH que el contrato puede contener en total.
* **Límite de Retiro (`i_limitRetiro`):** Se impone una restricción sobre la cantidad máxima de ETH que un usuario puede retirar en una sola transacción, previniendo grandes extracciones.
* **Seguridad:** Implementado con el patrón **Checks-Effects-Interactions** y utilizando la transferencia segura de ETH a través de `.call()`.
* **Transparencia:** Emite eventos para cada depósito y retiro exitoso, y registra contadores públicos de actividad.

## 🚀 Instrucciones de Despliegue

Este contrato requiere de dos parámetros iniciales e **inmutables** (que no se pueden cambiar después del despliegue) en su constructor.

### Requisitos Previos

* Un entorno de desarrollo Solidity (como **Hardhat**, **Foundry**, o **Remix**).
* Una billetera con ETH para cubrir el gas del despliegue.

### Parámetros del Constructor

El contrato `KipuBank` debe ser inicializado con los siguientes valores:

| Parámetro | Tipo | Descripción | Ejemplo (Wei) |
| :--- | :--- | :--- | :--- |
| `_limiteBancario` | `uint256` | El **límite total** de Ether que el banco puede almacenar. | `100 ether` (100000000000000000000) |
| `_limiteRetiro` | `uint256` | El **límite máximo** de retiro por transacción para un usuario. | `5 ether` (5000000000000000000) |

### Ejemplo de Despliegue (usando Hardhat/Ethers.js)

```javascript
// Asumiendo que el contrato ya está compilado
const KipuBank = await ethers.getContractFactory("KipuBank");

// Definir los límites en Wei (ej. 10 ETH de Capacidad, 1 ETH de Límite de Retiro)
const LIMIT_BANC = ethers.parseEther("10.0");
const LIMIT_RETIRO = ethers.parseEther("1.0");

const kipuBank = await KipuBank.deploy(LIMIT_BANC, LIMIT_RETIRO);

await kipuBank.waitForDeployment();

console.log(`KipuBank desplegado en: ${kipuBank.target}`);