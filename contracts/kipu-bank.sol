// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;


/**
 * @title Contrato bancario
 * @author Facundo Criado
*/
contract KipuBank {

    /*//////////////////////
            Variables
    /*//////////////////////

    ///@notice mapping que asocia la direccion del usuario con su saldo en el banco
    mapping (address user => uint256 balance) private s_balance;

    ///@notice Cantidad de depositos que se realizaron en el contrato
    uint256 public s_depositCount;

    ///@notice Cantidad de retiros que se realizaron en el contrato
    uint256 public s_withdrawalCount;

    ///@notice Limite de Saldo que el banco permite almacenar en total
    uint256 public immutable i_bankCapLimit;

    ///@notice Limite maximo de saldo que un usuario puede retirar en una transaccion
    uint256 public immutable i_withdrawalLimit;


    /*//////////////////////
            Eventos
    /*//////////////////////
    
    /// @notice Evento emitido cuando un deposito se realiza con exito.
    /// @param _sender La direccion que realizo el deposito
    /// @param _amount La cantidad de Saldo depositado
    event Deposited(address _sender, uint256 _amount);

    /// @notice Evento emitido cuando un retiro se realiza con exito
    /// @param _receiver La direccion que realizo el retiro
    /// @param _amount La cantidad de saldo retirado.
    event Withdrawn(address _receiver, uint256 _amount);


    /*//////////////////////
            Errores
    /*//////////////////////

    /// @notice Error cuando el monto a retirar excede el limite de retiro permitido por transaccion
    error ExceedsWithdrawLimit (uint256 _amount, uint256 _limit);

    /// @notice Error cuando un usuario intenta retirar mas fondos de los que tiene disponible
    error InsufficientBalance (uint256 _requered, uint256 _availableBalance);

    /// @notice Error cuando la cantidad total depositada excede el limite permitido por el banco
    error ExceedsBalanceBankLimit (uint256 _depositAmount, uint256 _availableAmount, uint256 _limitBank);

    /// @notice Error cuando el monto de una transaccion es cero
    error ZeroAmount();

    /// @notice Error cuando se envia Ether al contrato sin llamar a la funcion deposit().
    error DepositNotAllowed();

    /// @dev Modificador que asegura que el valor del parametro de una funcion o msg.value no es cero.
    modifier nonZeroAmount(uint256 _amount) {
        if ( _amount == 0) {
            revert ZeroAmount();
        }
        _;
    }


    /*//////////////////////
            Constructor
    /*//////////////////////

    constructor (uint256 _bankCapLimit, uint256 _withdrawalLimit) {
        i_bankCapLimit = _bankCapLimit;
        i_withdrawalLimit = _withdrawalLimit;
    }


    receive () external payable{
        _handleDeposit(msg.value);
    }

    fallback () external payable {
        revert DepositNotAllowed();
    }
 

    /*//////////////////////
        Funciones Publicas
    /*//////////////////////
    
    /// @notice Permite a los usuarios retirar saldo de su deposito almacenado.
    /// @param _amount La cantidad de saldo a retirar
    function withdrawal(uint256 _amount) external nonZeroAmount(_amount) {
        //check
        if (_amount > i_withdrawalLimit) {
                revert ExceedsWithdrawLimit (_amount, i_withdrawalLimit);
        }

        if (_amount > s_balance[msg.sender]) {
                revert InsufficientBalance (_amount, s_balance[msg.sender]);
        }

        //Effects
        s_balance[msg.sender] -= _amount;
        s_withdrawalCount++;

        //Interactions
        (bool success,) = msg.sender.call {value:_amount}("");
        require(success, "Fallo el envio del saldo");

        emit Withdrawn(msg.sender, _amount);
    }

    /// @notice 
    function deposit() external payable nonZeroAmount(msg.value) {
        _handleDeposit(msg.value);
    } 

    /// @notice Permite a los usuarios depositar saldo en su almacenamiento personal.
    /// @dev La funcion usa el modificador para chequear el msg.value y luego delega la logica interna
    function _handleDeposit(uint256 _amount) private {
        //Checks
        if (address(this).balance + _amount > i_bankCapLimit) {
                revert ExceedsBalanceBankLimit (_amount, address(this).balance - _amount, i_bankCapLimit);
        }

        //Effects
        s_balance[msg.sender] += _amount;
        s_depositCount++;

        //Interactions
        emit Deposited(msg.sender, _amount);
    }

    /// @notice Obtiene el saldo actual de un usuario
    /// @return Saldo del usuario
    function getBalance() public view returns (uint256) {
        return _getBalanceOf(msg.sender);
    }

    /*//////////////////////
        Funciones Privadas
    /*//////////////////////

    /// @param _user La direccion del usuario
    /// @return El saldo del usuario
    function _getBalanceOf (address _user) private view returns (uint256) {
        return s_balance[_user];
    }


}
