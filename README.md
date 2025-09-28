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

```

## 💻 Cómo Interactuar con el Contrato
Una vez desplegado, los usuarios pueden interactuar con el contrato KipuBank utilizando las siguientes funciones.

#### 1. Depositar Fondos (deposit) 📥
Permite a un usuario enviar ETH al contrato, aumentando su saldo personal en la bóveda.


| Detalle |	Valor |
| :--- | :--- |
| **Función** |	`depositar()` |
| **Tipo** |	`external payable` |
| **Requisitos** | Debe adjuntar el Ether que desea depositar a la llamada de la función (`msg.value`). |
| **Restriccion** | Restricción	Fallará si el depósito excede el límite total del banco (`i_limitBancario`). |

##### Ejemplo (Usando Ethers.js/Hardhat):

```JavaScript

// Asumiendo 'kipuBank' es la instancia del contrato
// Se depositará 0.5 ETH
await kipuBank.depositar({ value: ethers.parseEther("0.5") });

```

#### 2. Retirar Fondos (withdraw) 📤
Permite al usuario retirar una cantidad específica de su saldo depositado.

| Detalle | Valor |
| :--- | :--- |
| **Función** | `retirar(uint256 _cantidad)` |
| **Tipo** | `external` |
| **Parámetro** | `_cantidad` (la cantidad en Wei a retirar). |
| **Restricciones** | 1. No puede ser cero. 2. No puede exceder el i_limitRetiro. 3. No puede exceder el saldo del usuario.|


##### Ejemplo (Usando Ethers.js/Hardhat):

```JavaScript

// Se retirará 0.1 ETH
await kipuBank.retirar(ethers.parseEther("0.1"));
```

### 3. Consultar el Saldo Propio (getBalance) 🔎
Permite al usuario verificar cuánto ETH tiene depositado en su bóveda.

|Detalle | Valor |
| :--- | :--- |
| **Función** | `getSaldo()` |
| **Tipo** | `view` |
| **Devuelve** | `uint256` (el saldo del usuario en Wei). |
| **Costo** | Es una llamada gratuita que no cuesta gas. |

##### Ejemplo (Usando Ethers.js/Hardhat):

```JavaScript

const salgo = await kipuBank.getSaldo();
console.log(`Tu saldo es: ${ethers.formatEther(saldo)} ETH`);
```

### 4. Consultar Contadores y Límites (Funciones View) 📊
Puedes consultar el estado y las reglas del banco en cualquier momento. Todas son funciones gratuitas y de solo lectura.

* `i_limitbancario()`: Retorna la capacidad máxima total del banco.

* `i_limitRetiro()`: Retorna el límite máximo de retiro por transacción.

* `s_cantDepositos()`: Retorna el número total de depósitos realizados.

* `s_cantRetiros()`: Retorna el número total de retiros realizados.