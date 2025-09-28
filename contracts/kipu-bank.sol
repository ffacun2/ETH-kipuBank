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
    mapping (address usuario => uint256 saldo) private s_saldos;

    ///@notice Cantidad de depositos que se realizaron en el contrato
    uint256 public s_cantDepositos;

    ///@notice Cantidad de retiros que se realizaron en el contrato
    uint256 public s_cantRetiros;

    ///@notice Limite de Saldo que el banco permite almacenar en total
    uint256 public immutable i_limitBancario;

    ///@notice Limite maximo de saldo que un usuario puede retirar en una transaccion
    uint256 public immutable i_limitRetiro;


    /*//////////////////////
            Eventos
    /*//////////////////////
    
    /// @notice Evento emitido cuando un deposito se realiza con exito.
    /// @param _sender La direccion que realizo el deposito
    /// @param _cantidad La cantidad de Saldo depositado
    event KipuBank_Deposito(address _sender, uint256 _cantidad);

    /// @notice Evento emitido cuando un retiro se realiza con exito
    /// @param _receiver La direccion que realizo el retiro
    /// @param _cantidad La cantidad de saldo retirado.
    event KipuBank_Retiro(address _receiver, uint256 _cantidad);


    /*//////////////////////
            Errores
    /*//////////////////////

    /// @notice Error cuando el monto a retirar excede el limite de retiro permitido por transaccion
    error KipuBank_LimiteExcedidoRetiro (uint256 _cantidad, uint256 _limite);

    /// @notice Error cuando un usuario intenta retirar mas fondos de los que tiene disponible
    error KipuBank_SaldoInsuficiente (uint256 _requerido, uint256 _disponible);

    /// @notice Error cuando la cantidad total depositada excede el limite permitido por el banco
    error KipuBank_LimiteBancarioExcedido (uint256 _cantDeposito, uint256 _cantDisponible, uint256 _limiteBancario);

    /// @notice Error cuando el monto de una transaccion es cero
    error KipuBank_CantCero();

    modifier cantidadCero() {
        if (msg.value == 0) {
            revert KipuBank_CantCero();
        }
        _;
    }


    /*//////////////////////
            Constructor
    /*//////////////////////

    constructor (uint256 _limiteBancario, uint256 _limiteRetiro) {
        i_limitBancario = _limiteBancario;
        i_limitRetiro = _limiteRetiro;
    }


    /*//////////////////////
        Funciones Publicas
    /*//////////////////////
    
    /// @notice Permite a los usuarios retirar saldo de su deposito almacenado.
    /// @param _cantidad La cantidad de saldo a retirar
    function retiro (uint256 _cantidad) external {
        //check
        if (_cantidad > i_limitRetiro) {
                revert KipuBank_LimiteExcedidoRetiro(_cantidad, i_limitRetiro);
        }

        if (_cantidad > s_saldos[msg.sender]) {
                revert KipuBank_SaldoInsuficiente (_cantidad, s_saldos[msg.sender]);
        }

        //Effects
        s_saldos[msg.sender] -= _cantidad;
        s_cantRetiros++;

        //Interactions
        (bool success,) = msg.sender.call {value:_cantidad}("");
        require(success, "Fallo el envio del saldo");

        emit KipuBank_Retiro(msg.sender, _cantidad);
    }

    /// @notice Permite a los usuarios depositar saldo en su almacenamiento personal.
    function depositar () external payable {
        //Checks
        if (address(this).balance > i_limitBancario) {
                revert KipuBank_LimiteBancarioExcedido (msg.value, address(this).balance - msg.value, i_limitBancario);
        }

        //Effects
        s_saldos[msg.sender] += msg.value;
        s_cantDepositos++;

        //Interactions
        emit KipuBank_Deposito(msg.sender, msg.value);
    }

    /// @notice Obtiene el saldo actual de un usuario
    /// @return Saldo del usuario
    function getSaldo() public view returns (uint256) {
        return _getSaldo(msg.sender);
    }

    /*//////////////////////
        Funciones Privadas
    /*//////////////////////

    /// @param _usuario La direccion del usuario
    /// @return El saldo del usuario
    function _getSaldo (address _usuario) private view returns (uint256) {
        return s_saldos[_usuario];
    }


}