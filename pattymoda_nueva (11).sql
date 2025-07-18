-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 18-07-2025 a las 19:43:28
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `pattymoda_nueva`
--

DELIMITER $$
--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `obtener_igv_activo` () RETURNS DECIMAL(5,2) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE porcentaje DECIMAL(5,2) DEFAULT 0.00;
    
    SELECT ci.porcentaje INTO porcentaje
    FROM configuracion_impuestos ci
    WHERE ci.tipo = 'IGV' 
      AND ci.activo = 1 
      AND ci.aplicar_por_defecto = 1
    LIMIT 1;
    
    RETURN COALESCE(porcentaje, 0.00);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `siguiente_numero_venta` () RETURNS VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DETERMINISTIC READS SQL DATA BEGIN
    DECLARE siguiente VARCHAR(20);
    
    SELECT CONCAT('V', YEAR(NOW()), LPAD(
        COALESCE(
            MAX(CAST(SUBSTRING(numero_venta, 6) AS UNSIGNED)), 0
        ) + 1, 6, '0'
    )) INTO siguiente
    FROM ventas 
    WHERE numero_venta LIKE CONCAT('V', YEAR(NOW()), '%');
    
    RETURN siguiente;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `arqueos_caja`
--

CREATE TABLE `arqueos_caja` (
  `id` bigint(20) NOT NULL,
  `caja_id` bigint(20) NOT NULL,
  `fecha_arqueo` date NOT NULL,
  `turno` enum('MAÑANA','TARDE','NOCHE','COMPLETO') DEFAULT 'COMPLETO',
  `efectivo_inicio` decimal(10,2) NOT NULL DEFAULT 0.00,
  `efectivo_fin_sistema` decimal(10,2) NOT NULL DEFAULT 0.00,
  `efectivo_fin_fisico` decimal(10,2) NOT NULL DEFAULT 0.00,
  `diferencia` decimal(10,2) GENERATED ALWAYS AS (`efectivo_fin_fisico` - `efectivo_fin_sistema`) STORED,
  `total_ventas` decimal(10,2) DEFAULT 0.00,
  `total_gastos` decimal(10,2) DEFAULT 0.00,
  `observaciones` text DEFAULT NULL,
  `estado` enum('ABIERTO','CERRADO','CUADRADO','DESCUADRADO') DEFAULT 'ABIERTO',
  `usuario_apertura` bigint(20) DEFAULT NULL,
  `usuario_cierre` bigint(20) DEFAULT NULL,
  `fecha_apertura` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_cierre` timestamp NULL DEFAULT NULL,
  `fecha_actualizacion` timestamp NULL DEFAULT NULL,
  `fecha_creacion` timestamp NULL DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL,
  `creado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_logs`
--

CREATE TABLE `auditoria_logs` (
  `id` bigint(20) NOT NULL,
  `tabla` varchar(50) NOT NULL,
  `registro_id` bigint(20) NOT NULL,
  `accion` enum('INSERT','UPDATE','DELETE') NOT NULL,
  `datos_anteriores` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`datos_anteriores`)),
  `datos_nuevos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`datos_nuevos`)),
  `usuario_id` bigint(20) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  `fecha_accion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` datetime DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT NULL,
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cajas`
--

CREATE TABLE `cajas` (
  `id` bigint(20) NOT NULL,
  `codigo` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `ubicacion` varchar(100) DEFAULT NULL,
  `responsable_id` bigint(20) DEFAULT NULL,
  `monto_inicial` decimal(10,2) DEFAULT 0.00,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` datetime DEFAULT NULL,
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `cajas`
--

INSERT INTO `cajas` (`id`, `codigo`, `nombre`, `descripcion`, `ubicacion`, `responsable_id`, `monto_inicial`, `activo`, `fecha_creacion`, `fecha_actualizacion`, `creado_por`, `modificado_por`) VALUES
(1, 'CAJA01', 'Caja Principal', 'Caja principal de la tienda', 'Mostrador Principal', 1, 200.00, 1, '2025-07-17 23:28:34', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `canales_venta`
--

CREATE TABLE `canales_venta` (
  `id` bigint(20) NOT NULL,
  `codigo` varchar(20) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `comision_porcentaje` decimal(5,2) DEFAULT 0.00,
  `requiere_entrega` tinyint(1) DEFAULT 0,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `canales_venta`
--

INSERT INTO `canales_venta` (`id`, `codigo`, `nombre`, `descripcion`, `comision_porcentaje`, `requiere_entrega`, `activo`, `fecha_creacion`, `fecha_actualizacion`, `creado_por`, `modificado_por`) VALUES
(1, 'TIENDA', 'Tienda Física', 'Venta directa en tienda', 0.00, 0, 1, '2025-07-17 23:28:34', '2025-07-18 17:26:13', NULL, NULL),
(2, 'ONLINE', 'Tienda Online', 'Venta a través del sitio web', 2.50, 1, 1, '2025-07-17 23:28:34', '2025-07-18 17:26:13', NULL, NULL),
(3, 'WHATSAPP', 'WhatsApp', 'Venta por WhatsApp', 1.00, 1, 1, '2025-07-17 23:28:34', '2025-07-18 17:26:13', NULL, NULL),
(4, 'FACEBOOK', 'Facebook', 'Venta por Facebook', 1.50, 1, 1, '2025-07-17 23:28:34', '2025-07-18 17:26:13', NULL, NULL),
(5, 'INSTAGRAM', 'Instagram', 'Venta por Instagram', 1.50, 1, 1, '2025-07-17 23:28:34', '2025-07-18 17:26:13', NULL, NULL),
(6, 'TELEFONO', 'Teléfono', 'Venta telefónica', 0.50, 1, 1, '2025-07-17 23:28:34', '2025-07-18 17:26:13', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id` bigint(20) NOT NULL,
  `codigo` varchar(20) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `categoria_padre_id` bigint(20) DEFAULT NULL,
  `imagen` varchar(255) DEFAULT NULL,
  `icono` varchar(100) DEFAULT NULL,
  `orden` int(11) DEFAULT 0,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id`, `codigo`, `nombre`, `descripcion`, `categoria_padre_id`, `imagen`, `icono`, `orden`, `activo`, `fecha_creacion`, `fecha_actualizacion`, `creado_por`, `modificado_por`) VALUES
(1, 'ROPA_FEM', 'Ropa Femenina', 'Toda la ropa para mujeres', NULL, NULL, NULL, 1, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(2, 'ROPA_MASC', 'Ropa Masculina', 'Ropa para hombres', NULL, NULL, NULL, 2, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(3, 'ACCESORIOS', 'Accesorios', 'Complementos y accesorios', NULL, NULL, NULL, 3, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(4, 'CALZADO', 'Calzado', 'Zapatos y sandalias', NULL, NULL, NULL, 4, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(5, 'BLUSAS', 'Blusas', 'Blusas elegantes y casuales', 1, NULL, NULL, 1, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(6, 'VESTIDOS', 'Vestidos', 'Vestidos para toda ocasión', 1, NULL, NULL, 2, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(7, 'PANTALONES_F', 'Pantalones', 'Pantalones y jeans para mujeres', 1, NULL, NULL, 3, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(8, 'FALDAS', 'Faldas', 'Faldas modernas', 1, NULL, NULL, 4, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(9, 'CAMISAS', 'Camisas', 'Camisas formales y casuales', 2, NULL, NULL, 1, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(10, 'PANTALONES_M', 'Pantalones', 'Pantalones para hombres', 2, NULL, NULL, 2, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(11, 'POLOS', 'Polos', 'Polos deportivos y casuales', 2, NULL, NULL, 3, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(12, 'BOLSOS', 'Bolsos', 'Carteras y bolsos', 3, NULL, NULL, 1, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(13, 'CINTURONES', 'Cinturones', 'Cinturones de cuero y tela', 3, NULL, NULL, 2, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(14, 'JOYAS', 'Joyas', 'Collares, pulseras y aretes', 3, NULL, NULL, 3, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(15, 'ZAPATOS_FORM', 'Zapatos Formales', 'Zapatos para ocasiones especiales', 4, NULL, NULL, 1, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(16, 'ZAPATILLAS', 'Zapatillas', 'Calzado deportivo y casual', 4, NULL, NULL, 2, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL),
(17, 'SANDALIAS', 'Sandalias', 'Sandalias y chanclas', 4, NULL, NULL, 3, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `id` bigint(20) NOT NULL,
  `codigo_cliente` varchar(20) DEFAULT NULL,
  `tipo_documento` enum('DNI','RUC','PASAPORTE','CARNET_EXTRANJERIA') DEFAULT 'DNI',
  `numero_documento` varchar(20) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) DEFAULT NULL,
  `razon_social` varchar(200) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `genero` enum('M','F','OTRO') DEFAULT NULL,
  `estado_civil` enum('SOLTERO','CASADO','DIVORCIADO','VIUDO','OTRO') DEFAULT NULL,
  `ocupacion` varchar(100) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Disparadores `clientes`
--
DELIMITER $$
CREATE TRIGGER `before_insert_cliente` BEFORE INSERT ON `clientes` FOR EACH ROW BEGIN
    IF NEW.codigo_cliente IS NULL OR NEW.codigo_cliente = '' THEN
        SET NEW.codigo_cliente = CONCAT('CLI', LPAD(
            COALESCE(
                (SELECT MAX(CAST(SUBSTRING(codigo_cliente, 4) AS UNSIGNED))
                 FROM clientes 
                 WHERE codigo_cliente LIKE 'CLI%'), 0
            ) + 1, 6, '0'
        ));
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes_comercial`
--

CREATE TABLE `clientes_comercial` (
  `id` bigint(20) NOT NULL,
  `cliente_id` bigint(20) NOT NULL,
  `tipo_cliente` enum('REGULAR','VIP','MAYORISTA','MINORISTA','CORPORATIVO') DEFAULT 'REGULAR',
  `limite_credito` decimal(10,2) DEFAULT 0.00,
  `descuento_personalizado` decimal(5,2) DEFAULT 0.00,
  `metodo_pago_preferido` varchar(50) DEFAULT NULL,
  `total_compras` decimal(12,2) DEFAULT 0.00,
  `cantidad_compras` int(11) DEFAULT 0,
  `ultima_compra` timestamp NULL DEFAULT NULL,
  `fecha_ultimo_contacto` timestamp NULL DEFAULT NULL,
  `origen_cliente` enum('WEB','REFERIDO','PUBLICIDAD','WALK_IN','REDES_SOCIALES') DEFAULT 'WALK_IN',
  `vendedor_asignado_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes_contacto`
--

CREATE TABLE `clientes_contacto` (
  `id` bigint(20) NOT NULL,
  `cliente_id` bigint(20) NOT NULL,
  `tipo_contacto` enum('EMAIL','TELEFONO','WHATSAPP','FACEBOOK','INSTAGRAM') NOT NULL,
  `valor` varchar(200) NOT NULL,
  `es_principal` tinyint(1) DEFAULT 0,
  `verificado` tinyint(1) DEFAULT 0,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes_direcciones`
--

CREATE TABLE `clientes_direcciones` (
  `id` bigint(20) NOT NULL,
  `cliente_id` bigint(20) NOT NULL,
  `tipo_direccion` enum('CASA','TRABAJO','ENTREGA','FACTURACION','OTRO') DEFAULT 'CASA',
  `direccion` varchar(255) NOT NULL,
  `distrito_id` bigint(20) DEFAULT NULL,
  `referencia` varchar(255) DEFAULT NULL,
  `codigo_postal` varchar(10) DEFAULT NULL,
  `es_principal` tinyint(1) DEFAULT 0,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes_preferencias`
--

CREATE TABLE `clientes_preferencias` (
  `id` bigint(20) NOT NULL,
  `cliente_id` bigint(20) NOT NULL,
  `categoria_preferida_id` bigint(20) DEFAULT NULL,
  `talla_preferida_id` bigint(20) DEFAULT NULL,
  `color_preferido_id` bigint(20) DEFAULT NULL,
  `marca_preferida_id` bigint(20) DEFAULT NULL,
  `canal_preferido_id` bigint(20) DEFAULT NULL,
  `recibir_promociones` tinyint(1) DEFAULT 1,
  `recibir_newsletter` tinyint(1) DEFAULT 1,
  `frecuencia_contacto` enum('DIARIO','SEMANAL','MENSUAL','NUNCA') DEFAULT 'MENSUAL',
  `notas` text DEFAULT NULL,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `colores`
--

CREATE TABLE `colores` (
  `id` bigint(20) NOT NULL,
  `codigo` varchar(20) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `codigo_hex` varchar(7) NOT NULL,
  `codigo_rgb` varchar(20) DEFAULT NULL,
  `familia_color` varchar(30) DEFAULT NULL,
  `orden_visualizacion` int(11) DEFAULT 0,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `colores`
--

INSERT INTO `colores` (`id`, `codigo`, `nombre`, `descripcion`, `codigo_hex`, `codigo_rgb`, `familia_color`, `orden_visualizacion`, `activo`, `fecha_creacion`, `creado_por`, `fecha_actualizacion`, `modificado_por`) VALUES
(1, 'NEG', 'Negro', 'Negro clásico', '#000000', '0,0,0', 'Neutros', 1, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(2, 'BLA', 'Blanco', 'Blanco puro', '#FFFFFF', '255,255,255', 'Neutros', 2, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(3, 'GRI', 'Gris', 'Gris medio', '#808080', '128,128,128', 'Neutros', 3, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(4, 'ROJ', 'Rojo', 'Rojo clásico', '#FF0000', '255,0,0', 'Rojos', 10, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(5, 'ROJ_VIN', 'Rojo Vino', 'Rojo vino elegante', '#722F37', '114,47,55', 'Rojos', 11, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(6, 'ROJ_COR', 'Rojo Coral', 'Rojo coral vibrante', '#FF7F7F', '255,127,127', 'Rojos', 12, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(7, 'AZU', 'Azul', 'Azul clásico', '#0000FF', '0,0,255', 'Azules', 20, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(8, 'AZU_MAR', 'Azul Marino', 'Azul marino profundo', '#000080', '0,0,128', 'Azules', 21, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(9, 'AZU_CIE', 'Azul Cielo', 'Azul cielo claro', '#87CEEB', '135,206,235', 'Azules', 22, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(10, 'VER', 'Verde', 'Verde clásico', '#008000', '0,128,0', 'Verdes', 30, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(11, 'VER_OLI', 'Verde Oliva', 'Verde oliva natural', '#808000', '128,128,0', 'Verdes', 31, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(12, 'ROS', 'Rosa', 'Rosa suave', '#FFC0CB', '255,192,203', 'Rosas', 40, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(13, 'MOR', 'Morado', 'Morado elegante', '#800080', '128,0,128', 'Morados', 41, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(14, 'AMA', 'Amarillo', 'Amarillo brillante', '#FFFF00', '255,255,0', 'Amarillos', 50, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(15, 'NAR', 'Naranja', 'Naranja vibrante', '#FFA500', '255,165,0', 'Naranjas', 51, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(16, 'MAR', 'Marrón', 'Marrón clásico', '#A52A2A', '165,42,42', 'Marrones', 60, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL),
(17, 'BEI', 'Beige', 'Beige natural', '#F5F5DC', '245,245,220', 'Marrones', 61, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:21:51', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compras`
--

CREATE TABLE `compras` (
  `id` bigint(20) NOT NULL,
  `numero_compra` varchar(20) NOT NULL,
  `proveedor_id` bigint(20) NOT NULL,
  `fecha_compra` date NOT NULL,
  `fecha_entrega_esperada` date DEFAULT NULL,
  `fecha_entrega_real` date DEFAULT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `descuento_porcentaje` decimal(5,2) DEFAULT 0.00,
  `descuento_monto` decimal(10,2) DEFAULT 0.00,
  `impuesto_porcentaje` decimal(5,2) DEFAULT 0.00,
  `impuesto_monto` decimal(10,2) DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL,
  `estado` enum('PENDIENTE','CONFIRMADA','PARCIAL','RECIBIDA','CANCELADA') DEFAULT 'PENDIENTE',
  `tipo_comprobante` enum('FACTURA','BOLETA','RECIBO','ORDEN_COMPRA') DEFAULT 'FACTURA',
  `numero_comprobante` varchar(50) DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Disparadores `compras`
--
DELIMITER $$
CREATE TRIGGER `after_update_compra_recibida` AFTER UPDATE ON `compras` FOR EACH ROW BEGIN
    IF OLD.estado != 'RECIBIDA' AND NEW.estado = 'RECIBIDA' THEN
        -- Actualizar stock para todos los productos de la compra
        UPDATE productos_inventario pi
        JOIN detalle_compra dc ON pi.producto_id = dc.producto_id
        SET pi.stock_actual = pi.stock_actual + dc.cantidad_recibida,
            pi.fecha_ultimo_movimiento = CURRENT_TIMESTAMP
        WHERE dc.compra_id = NEW.id;
        
        -- Registrar movimientos de inventario
        INSERT INTO movimientos_inventario 
        (producto_id, tipo_movimiento, motivo, cantidad_anterior, cantidad_movimiento, cantidad_actual, compra_id, usuario_id, costo_unitario, valor_total)
        SELECT 
            dc.producto_id,
            'ENTRADA',
            'COMPRA',
            pi.stock_actual - dc.cantidad_recibida,
            dc.cantidad_recibida,
            pi.stock_actual,
            NEW.id,
            COALESCE(NEW.creado_por, 1),
            dc.precio_unitario,
            dc.precio_unitario * dc.cantidad_recibida
        FROM detalle_compra dc
        JOIN productos_inventario pi ON dc.producto_id = pi.producto_id
        WHERE dc.compra_id = NEW.id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion_impuestos`
--

CREATE TABLE `configuracion_impuestos` (
  `id` bigint(20) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `codigo` varchar(10) NOT NULL,
  `porcentaje` decimal(5,2) NOT NULL,
  `tipo` enum('IGV','ISC','MUNICIPAL','OTROS') DEFAULT 'OTROS',
  `activo` tinyint(1) DEFAULT 1,
  `aplicar_por_defecto` tinyint(1) DEFAULT 0,
  `aplica_a_productos` tinyint(1) DEFAULT 1,
  `aplica_a_servicios` tinyint(1) DEFAULT 1,
  `descripcion` varchar(200) DEFAULT NULL,
  `base_legal` varchar(500) DEFAULT NULL,
  `fecha_vigencia_inicio` date DEFAULT NULL,
  `fecha_vigencia_fin` date DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `configuracion_impuestos`
--

INSERT INTO `configuracion_impuestos` (`id`, `nombre`, `codigo`, `porcentaje`, `tipo`, `activo`, `aplicar_por_defecto`, `aplica_a_productos`, `aplica_a_servicios`, `descripcion`, `base_legal`, `fecha_vigencia_inicio`, `fecha_vigencia_fin`, `fecha_creacion`, `fecha_actualizacion`, `creado_por`) VALUES
(1, 'IGV Selva', 'IGV_SEL', 0.00, 'IGV', 1, 1, 1, 1, 'IGV para región de la selva - Exonerado según Ley de Promoción de la Inversión en la Amazonía', 'Ley N° 27037 - Ley de Promoción de la Inversión en la Amazonía', NULL, NULL, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1),
(2, 'IGV Estándar', 'IGV_STD', 18.00, 'IGV', 0, 0, 1, 1, 'IGV estándar del 18% para otras regiones del Perú', 'TUO del IGV - D.S. N° 055-99-EF', NULL, NULL, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1),
(3, 'ISC Textiles', 'ISC_TEX', 0.00, 'ISC', 0, 0, 1, 1, 'Impuesto Selectivo al Consumo para productos textiles', 'TUO del ISC - D.S. N° 055-99-EF', NULL, NULL, '2025-07-17 23:28:34', '2025-07-17 23:28:34', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion_tienda`
--

CREATE TABLE `configuracion_tienda` (
  `id` bigint(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `slogan` varchar(200) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `ruc` varchar(11) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `distrito_id` bigint(20) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `telefono_secundario` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `email_ventas` varchar(100) DEFAULT NULL,
  `email_soporte` varchar(100) DEFAULT NULL,
  `sitio_web` varchar(100) DEFAULT NULL,
  `facebook` varchar(100) DEFAULT NULL,
  `instagram` varchar(100) DEFAULT NULL,
  `whatsapp` varchar(20) DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `favicon` varchar(255) DEFAULT NULL,
  `moneda_principal` varchar(3) DEFAULT 'PEN',
  `idioma_principal` varchar(5) DEFAULT 'es_PE',
  `zona_horaria` varchar(50) DEFAULT 'America/Lima',
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `configuracion_tienda`
--

INSERT INTO `configuracion_tienda` (`id`, `nombre`, `slogan`, `descripcion`, `ruc`, `direccion`, `distrito_id`, `telefono`, `telefono_secundario`, `email`, `email_ventas`, `email_soporte`, `sitio_web`, `facebook`, `instagram`, `whatsapp`, `logo`, `favicon`, `moneda_principal`, `idioma_principal`, `zona_horaria`, `activo`, `fecha_creacion`, `fecha_actualizacion`, `creado_por`, `modificado_por`) VALUES
(1, 'DPattyModa', 'Moda y Estilo en la Selva', 'Tienda especializada en ropa moderna y elegante ubicada en Pampa Hermosa, Loreto. Ofrecemos las últimas tendencias en moda femenina y masculina.', NULL, 'Av. Principal 123', 3, '+51 965 123 456', NULL, 'info@dpattymoda.com', NULL, NULL, NULL, NULL, NULL, '+51 965 123 456', NULL, NULL, 'PEN', 'es_PE', 'America/Lima', 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cotizaciones`
--

CREATE TABLE `cotizaciones` (
  `id` bigint(20) NOT NULL,
  `numero_cotizacion` varchar(20) NOT NULL,
  `cliente_id` bigint(20) NOT NULL,
  `fecha_cotizacion` date NOT NULL,
  `fecha_vencimiento` date NOT NULL,
  `subtotal` decimal(12,2) DEFAULT 0.00,
  `descuento_porcentaje` decimal(5,2) DEFAULT 0.00,
  `descuento_monto` decimal(10,2) DEFAULT 0.00,
  `impuesto_porcentaje` decimal(5,2) DEFAULT 0.00,
  `impuesto_monto` decimal(10,2) DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL,
  `estado` enum('PENDIENTE','ENVIADA','APROBADA','RECHAZADA','VENCIDA','CONVERTIDA') DEFAULT 'PENDIENTE',
  `observaciones` text DEFAULT NULL,
  `condiciones_comerciales` text DEFAULT NULL,
  `vendedor_id` bigint(20) DEFAULT NULL,
  `venta_id` bigint(20) DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `departamentos`
--

CREATE TABLE `departamentos` (
  `id` bigint(20) NOT NULL,
  `pais_id` bigint(20) NOT NULL,
  `codigo` varchar(10) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `departamentos`
--

INSERT INTO `departamentos` (`id`, `pais_id`, `codigo`, `nombre`, `activo`) VALUES
(1, 1, 'LOR', 'Loreto', 1),
(2, 1, 'LIM', 'Lima', 1),
(3, 1, 'ARE', 'Arequipa', 1),
(4, 1, 'CUS', 'Cusco', 1),
(5, 1, 'LAL', 'La Libertad', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_compra`
--

CREATE TABLE `detalle_compra` (
  `id` bigint(20) NOT NULL,
  `compra_id` bigint(20) NOT NULL,
  `producto_id` bigint(20) NOT NULL,
  `cantidad_pedida` int(11) NOT NULL,
  `cantidad_recibida` int(11) DEFAULT 0,
  `precio_unitario` decimal(10,2) NOT NULL,
  `descuento_porcentaje` decimal(5,2) DEFAULT 0.00,
  `descuento_monto` decimal(10,2) DEFAULT 0.00,
  `subtotal` decimal(10,2) NOT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `lote` varchar(50) DEFAULT NULL,
  `observaciones` varchar(500) DEFAULT NULL,
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_cotizacion`
--

CREATE TABLE `detalle_cotizacion` (
  `id` bigint(20) NOT NULL,
  `cotizacion_id` bigint(20) NOT NULL,
  `producto_id` bigint(20) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `talla_id` bigint(20) DEFAULT NULL,
  `color_id` bigint(20) DEFAULT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `descuento_porcentaje` decimal(5,2) DEFAULT 0.00,
  `descuento_monto` decimal(10,2) DEFAULT 0.00,
  `subtotal` decimal(10,2) NOT NULL,
  `observaciones` varchar(500) DEFAULT NULL,
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_devolucion`
--

CREATE TABLE `detalle_devolucion` (
  `id` bigint(20) NOT NULL,
  `devolucion_id` bigint(20) NOT NULL,
  `detalle_venta_id` bigint(20) NOT NULL,
  `cantidad_devuelta` int(11) NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `condicion_producto` enum('NUEVO','USADO_BUENO','USADO_REGULAR','DEFECTUOSO') DEFAULT 'NUEVO',
  `observaciones` varchar(500) DEFAULT NULL,
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_transferencia`
--

CREATE TABLE `detalle_transferencia` (
  `id` bigint(20) NOT NULL,
  `transferencia_id` bigint(20) NOT NULL,
  `producto_id` bigint(20) NOT NULL,
  `cantidad_enviada` int(11) NOT NULL,
  `cantidad_recibida` int(11) DEFAULT 0,
  `observaciones` varchar(500) DEFAULT NULL,
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_venta`
--

CREATE TABLE `detalle_venta` (
  `id` bigint(20) NOT NULL,
  `venta_id` bigint(20) NOT NULL,
  `producto_id` bigint(20) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `talla_id` bigint(20) DEFAULT NULL,
  `color_id` bigint(20) DEFAULT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `precio_original` decimal(10,2) DEFAULT NULL,
  `descuento_porcentaje` decimal(5,2) DEFAULT 0.00,
  `descuento_monto` decimal(10,2) DEFAULT 0.00,
  `subtotal` decimal(10,2) NOT NULL,
  `costo_unitario` decimal(10,2) DEFAULT NULL,
  `margen_ganancia` decimal(10,2) GENERATED ALWAYS AS (`precio_unitario` - coalesce(`costo_unitario`,0)) STORED,
  `notas` varchar(500) DEFAULT NULL,
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Disparadores `detalle_venta`
--
DELIMITER $$
CREATE TRIGGER `after_insert_detalle_venta` AFTER INSERT ON `detalle_venta` FOR EACH ROW BEGIN
    -- Actualizar stock del producto
    UPDATE productos_inventario 
    SET stock_actual = stock_actual - NEW.cantidad,
        fecha_ultimo_movimiento = CURRENT_TIMESTAMP
    WHERE producto_id = NEW.producto_id;
    
    -- Registrar movimiento de inventario
    INSERT INTO movimientos_inventario 
    (producto_id, tipo_movimiento, motivo, cantidad_anterior, cantidad_movimiento, cantidad_actual, venta_id, usuario_id)
    SELECT 
        NEW.producto_id,
        'SALIDA',
        'VENTA',
        pi.stock_actual + NEW.cantidad,
        NEW.cantidad,
        pi.stock_actual,
        NEW.venta_id,
        COALESCE((SELECT creado_por FROM ventas WHERE id = NEW.venta_id), 1)
    FROM productos_inventario pi 
    WHERE pi.producto_id = NEW.producto_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `devoluciones`
--

CREATE TABLE `devoluciones` (
  `id` bigint(20) NOT NULL,
  `numero_devolucion` varchar(20) NOT NULL,
  `venta_id` bigint(20) NOT NULL,
  `cliente_id` bigint(20) NOT NULL,
  `fecha_devolucion` timestamp NOT NULL DEFAULT current_timestamp(),
  `motivo` enum('DEFECTO_PRODUCTO','TALLA_INCORRECTA','COLOR_INCORRECTO','NO_SATISFECHO','CAMBIO_OPINION','GARANTIA','OTRO') NOT NULL,
  `descripcion_motivo` text DEFAULT NULL,
  `subtotal_devuelto` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total_devuelto` decimal(10,2) NOT NULL,
  `estado` enum('PENDIENTE','APROBADA','RECHAZADA','PROCESADA') DEFAULT 'PENDIENTE',
  `tipo_devolucion` enum('REEMBOLSO','CAMBIO','NOTA_CREDITO') DEFAULT 'REEMBOLSO',
  `autorizado_por` bigint(20) DEFAULT NULL,
  `procesado_por` bigint(20) DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `distritos`
--

CREATE TABLE `distritos` (
  `id` bigint(20) NOT NULL,
  `provincia_id` bigint(20) NOT NULL,
  `codigo` varchar(10) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  `codigo_postal` varchar(10) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `distritos`
--

INSERT INTO `distritos` (`id`, `provincia_id`, `codigo`, `nombre`, `codigo_postal`, `activo`) VALUES
(1, 2, 'CON', 'Contamana', '16501', 1),
(2, 2, 'INA', 'Inahuaya', '16502', 1),
(3, 2, 'PAM', 'Pampa Hermosa', '16503', 1),
(4, 2, 'SAR', 'Sarayacu', '16504', 1),
(5, 2, 'VAR', 'Vargas Guerra', '16505', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gastos`
--

CREATE TABLE `gastos` (
  `id` bigint(20) NOT NULL,
  `numero_gasto` varchar(20) NOT NULL,
  `tipo_gasto_id` bigint(20) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `fecha_gasto` date NOT NULL,
  `descripcion` text NOT NULL,
  `proveedor_id` bigint(20) DEFAULT NULL,
  `numero_comprobante` varchar(50) DEFAULT NULL,
  `tipo_comprobante` enum('FACTURA','BOLETA','RECIBO','TICKET','OTROS') DEFAULT 'RECIBO',
  `estado` enum('PENDIENTE','APROBADO','PAGADO','RECHAZADO') DEFAULT 'PENDIENTE',
  `autorizado_por` bigint(20) DEFAULT NULL,
  `pagado_por` bigint(20) DEFAULT NULL,
  `caja_id` bigint(20) DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `archivo_comprobante` varchar(255) DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `horarios_atencion`
--

CREATE TABLE `horarios_atencion` (
  `id` bigint(20) NOT NULL,
  `dia_semana` enum('LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO','DOMINGO') NOT NULL,
  `hora_apertura` time DEFAULT NULL,
  `hora_cierre` time DEFAULT NULL,
  `cerrado` tinyint(1) DEFAULT 0,
  `observaciones` varchar(200) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `horarios_atencion`
--

INSERT INTO `horarios_atencion` (`id`, `dia_semana`, `hora_apertura`, `hora_cierre`, `cerrado`, `observaciones`, `activo`) VALUES
(1, 'LUNES', '09:00:00', '20:00:00', 0, NULL, 1),
(2, 'MARTES', '09:00:00', '20:00:00', 0, NULL, 1),
(3, 'MIERCOLES', '09:00:00', '20:00:00', 0, NULL, 1),
(4, 'JUEVES', '09:00:00', '20:00:00', 0, NULL, 1),
(5, 'VIERNES', '09:00:00', '20:00:00', 0, NULL, 1),
(6, 'SABADO', '09:00:00', '21:00:00', 0, NULL, 1),
(7, 'DOMINGO', '10:00:00', '18:00:00', 0, NULL, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `interacciones_cliente`
--

CREATE TABLE `interacciones_cliente` (
  `id` bigint(20) NOT NULL,
  `cliente_id` bigint(20) NOT NULL,
  `tipo_interaccion` enum('LLAMADA','EMAIL','WHATSAPP','VISITA','RECLAMO','CONSULTA','SEGUIMIENTO','OTROS') NOT NULL,
  `canal` enum('TELEFONO','EMAIL','WHATSAPP','PRESENCIAL','WEB','REDES_SOCIALES') NOT NULL,
  `asunto` varchar(200) DEFAULT NULL,
  `descripcion` text NOT NULL,
  `estado` enum('PENDIENTE','EN_PROCESO','RESUELTO','CERRADO') DEFAULT 'PENDIENTE',
  `prioridad` enum('BAJA','MEDIA','ALTA','URGENTE') DEFAULT 'MEDIA',
  `fecha_interaccion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_seguimiento` date DEFAULT NULL,
  `usuario_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `marcas`
--

CREATE TABLE `marcas` (
  `id` bigint(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `sitio_web` varchar(200) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `marcas`
--

INSERT INTO `marcas` (`id`, `nombre`, `descripcion`, `logo`, `sitio_web`, `activo`, `fecha_creacion`, `creado_por`, `fecha_actualizacion`, `modificado_por`) VALUES
(1, 'PattyModa', 'Marca propia de la tienda', NULL, NULL, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:22:01', NULL),
(2, 'Zara', 'Moda internacional', NULL, NULL, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:22:01', NULL),
(3, 'H&M', 'Moda accesible', NULL, NULL, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:22:01', NULL),
(4, 'Nike', 'Ropa deportiva', NULL, NULL, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:22:01', NULL),
(5, 'Adidas', 'Ropa deportiva', NULL, NULL, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:22:01', NULL),
(6, 'Levi\'s', 'Jeans y casual wear', NULL, NULL, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:22:01', NULL),
(7, 'Forever 21', 'Moda juvenil', NULL, NULL, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:22:01', NULL),
(8, 'Mango', 'Moda europea', NULL, NULL, 1, '2025-07-17 23:28:34', NULL, '2025-07-18 17:22:01', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metodos_pago_venta`
--

CREATE TABLE `metodos_pago_venta` (
  `id` bigint(20) NOT NULL,
  `venta_id` bigint(20) NOT NULL,
  `tipo_pago` enum('EFECTIVO','TARJETA_DEBITO','TARJETA_CREDITO','YAPE','PLIN','TRANSFERENCIA','CHEQUE','CREDITO') NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `referencia` varchar(100) DEFAULT NULL,
  `numero_operacion` varchar(50) DEFAULT NULL,
  `banco` varchar(100) DEFAULT NULL,
  `tipo_tarjeta` varchar(50) DEFAULT NULL,
  `ultimos_4_digitos` varchar(4) DEFAULT NULL,
  `numero_cuotas` int(11) DEFAULT 1,
  `tasa_interes` decimal(5,2) DEFAULT 0.00,
  `comision` decimal(10,2) DEFAULT 0.00,
  `estado` enum('PENDIENTE','APROBADO','RECHAZADO','ANULADO') DEFAULT 'APROBADO',
  `fecha_pago` timestamp NOT NULL DEFAULT current_timestamp(),
  `notas` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimientos_caja`
--

CREATE TABLE `movimientos_caja` (
  `id` bigint(20) NOT NULL,
  `caja_id` bigint(20) NOT NULL,
  `arqueo_id` bigint(20) DEFAULT NULL,
  `tipo_movimiento` enum('ENTRADA','SALIDA') NOT NULL,
  `concepto` enum('VENTA','GASTO','PRESTAMO','DEVOLUCION','CAMBIO','APERTURA','CIERRE','AJUSTE','OTROS') NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `descripcion` varchar(500) DEFAULT NULL,
  `referencia` varchar(100) DEFAULT NULL,
  `venta_id` bigint(20) DEFAULT NULL,
  `gasto_id` bigint(20) DEFAULT NULL,
  `fecha_movimiento` timestamp NOT NULL DEFAULT current_timestamp(),
  `usuario_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimientos_inventario`
--

CREATE TABLE `movimientos_inventario` (
  `id` bigint(20) NOT NULL,
  `producto_id` bigint(20) NOT NULL,
  `tipo_movimiento` enum('ENTRADA','SALIDA','AJUSTE','TRANSFERENCIA','DEVOLUCION') NOT NULL,
  `motivo` enum('COMPRA','VENTA','AJUSTE_INVENTARIO','MERMA','ROBO','DEVOLUCION_CLIENTE','DEVOLUCION_PROVEEDOR','PROMOCION','MUESTRA','TRANSFERENCIA','OTROS') NOT NULL,
  `cantidad_anterior` int(11) NOT NULL,
  `cantidad_movimiento` int(11) NOT NULL,
  `cantidad_actual` int(11) NOT NULL,
  `costo_unitario` decimal(10,2) DEFAULT NULL,
  `valor_total` decimal(12,2) DEFAULT NULL,
  `referencia_documento` varchar(100) DEFAULT NULL,
  `lote` varchar(50) DEFAULT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `venta_id` bigint(20) DEFAULT NULL,
  `compra_id` bigint(20) DEFAULT NULL,
  `devolucion_id` bigint(20) DEFAULT NULL,
  `transferencia_id` bigint(20) DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `fecha_movimiento` timestamp NOT NULL DEFAULT current_timestamp(),
  `usuario_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `paises`
--

CREATE TABLE `paises` (
  `id` bigint(20) NOT NULL,
  `codigo_iso` varchar(3) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `codigo_telefono` varchar(5) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `paises`
--

INSERT INTO `paises` (`id`, `codigo_iso`, `nombre`, `codigo_telefono`, `activo`, `fecha_creacion`) VALUES
(1, 'PER', 'Perú', '+51', 1, '2025-07-17 23:28:34'),
(2, 'COL', 'Colombia', '+57', 1, '2025-07-17 23:28:34'),
(3, 'ECU', 'Ecuador', '+593', 1, '2025-07-17 23:28:34'),
(4, 'BOL', 'Bolivia', '+591', 1, '2025-07-17 23:28:34'),
(5, 'BRA', 'Brasil', '+55', 1, '2025-07-17 23:28:34');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `id` bigint(20) NOT NULL,
  `usuario_id` bigint(20) NOT NULL,
  `token` varchar(255) NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_expiracion` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `usado` tinyint(1) DEFAULT 0,
  `ip_solicitud` varchar(45) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permisos`
--

CREATE TABLE `permisos` (
  `id` bigint(20) NOT NULL,
  `codigo` varchar(50) NOT NULL,
  `modulo` varchar(50) NOT NULL,
  `accion` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `permisos`
--

INSERT INTO `permisos` (`id`, `codigo`, `modulo`, `accion`, `descripcion`, `activo`) VALUES
(1, 'PRODUCTOS_VER', 'PRODUCTOS', 'VER', 'Ver productos', 1),
(2, 'PRODUCTOS_CREAR', 'PRODUCTOS', 'CREAR', 'Crear productos', 1),
(3, 'PRODUCTOS_EDITAR', 'PRODUCTOS', 'EDITAR', 'Editar productos', 1),
(4, 'PRODUCTOS_ELIMINAR', 'PRODUCTOS', 'ELIMINAR', 'Eliminar productos', 1),
(5, 'VENTAS_VER', 'VENTAS', 'VER', 'Ver ventas', 1),
(6, 'VENTAS_CREAR', 'VENTAS', 'CREAR', 'Crear ventas', 1),
(7, 'VENTAS_EDITAR', 'VENTAS', 'EDITAR', 'Editar ventas', 1),
(8, 'VENTAS_ANULAR', 'VENTAS', 'ANULAR', 'Anular ventas', 1),
(9, 'CLIENTES_VER', 'CLIENTES', 'VER', 'Ver clientes', 1),
(10, 'CLIENTES_CREAR', 'CLIENTES', 'CREAR', 'Crear clientes', 1),
(11, 'CLIENTES_EDITAR', 'CLIENTES', 'EDITAR', 'Editar clientes', 1),
(12, 'INVENTARIO_VER', 'INVENTARIO', 'VER', 'Ver inventario', 1),
(13, 'INVENTARIO_AJUSTAR', 'INVENTARIO', 'AJUSTAR', 'Ajustar inventario', 1),
(14, 'REPORTES_VER', 'REPORTES', 'VER', 'Ver reportes', 1),
(15, 'REPORTES_AVANZADOS', 'REPORTES', 'AVANZADOS', 'Ver reportes avanzados', 1),
(16, 'CONFIG_VER', 'CONFIGURACION', 'VER', 'Ver configuración', 1),
(17, 'CONFIG_EDITAR', 'CONFIGURACION', 'EDITAR', 'Editar configuración', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id` bigint(20) NOT NULL,
  `codigo_producto` varchar(50) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `sku` varchar(100) NOT NULL,
  `codigo_barras` varchar(50) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `descripcion_corta` varchar(500) DEFAULT NULL,
  `categoria_id` bigint(20) NOT NULL,
  `marca_id` bigint(20) DEFAULT NULL,
  `modelo` varchar(100) DEFAULT NULL,
  `unidad_medida_id` bigint(20) DEFAULT NULL,
  `peso` decimal(8,3) DEFAULT NULL,
  `dimensiones` varchar(100) DEFAULT NULL,
  `imagen_principal` varchar(255) DEFAULT NULL,
  `requiere_talla` tinyint(1) DEFAULT 1,
  `requiere_color` tinyint(1) DEFAULT 1,
  `es_perecedero` tinyint(1) DEFAULT 0,
  `tiempo_entrega_dias` int(11) DEFAULT 1,
  `garantia_meses` int(11) DEFAULT 0,
  `destacado` tinyint(1) DEFAULT 0,
  `nuevo` tinyint(1) DEFAULT 1,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos_colores`
--

CREATE TABLE `productos_colores` (
  `id` bigint(20) NOT NULL,
  `producto_id` bigint(20) NOT NULL,
  `color_id` bigint(20) NOT NULL,
  `stock_color` int(11) NOT NULL DEFAULT 0,
  `precio_adicional` decimal(10,2) DEFAULT 0.00,
  `imagen_color` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos_imagenes`
--

CREATE TABLE `productos_imagenes` (
  `id` bigint(20) NOT NULL,
  `producto_id` bigint(20) NOT NULL,
  `url_imagen` varchar(255) NOT NULL,
  `alt_text` varchar(255) DEFAULT NULL,
  `orden` int(11) DEFAULT 0,
  `es_principal` tinyint(1) DEFAULT 0,
  `color_id` bigint(20) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos_inventario`
--

CREATE TABLE `productos_inventario` (
  `id` bigint(20) NOT NULL,
  `producto_id` bigint(20) NOT NULL,
  `stock_actual` int(11) NOT NULL DEFAULT 0,
  `stock_minimo` int(11) DEFAULT 5,
  `stock_maximo` int(11) DEFAULT NULL,
  `stock_reservado` int(11) DEFAULT 0,
  `stock_disponible` int(11) GENERATED ALWAYS AS (`stock_actual` - `stock_reservado`) STORED,
  `ubicacion_almacen` varchar(100) DEFAULT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `lote` varchar(50) DEFAULT NULL,
  `fecha_ultimo_movimiento` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `fecha_ultimo_inventario` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos_precios`
--

CREATE TABLE `productos_precios` (
  `id` bigint(20) NOT NULL,
  `producto_id` bigint(20) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL,
  `precio_oferta` decimal(10,2) DEFAULT NULL,
  `costo` decimal(10,2) DEFAULT NULL,
  `margen_porcentaje` decimal(5,2) GENERATED ALWAYS AS (case when `precio_venta` > 0 then (`precio_venta` - coalesce(`costo`,0)) / `precio_venta` * 100 else 0 end) STORED,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `motivo_cambio` varchar(200) DEFAULT NULL,
  `usuario_id` bigint(20) DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos_seo`
--

CREATE TABLE `productos_seo` (
  `id` bigint(20) NOT NULL,
  `producto_id` bigint(20) NOT NULL,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` varchar(500) DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tags`)),
  `palabras_clave` text DEFAULT NULL,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos_tallas`
--

CREATE TABLE `productos_tallas` (
  `id` bigint(20) NOT NULL,
  `producto_id` bigint(20) NOT NULL,
  `talla_id` bigint(20) NOT NULL,
  `stock_talla` int(11) NOT NULL DEFAULT 0,
  `precio_adicional` decimal(10,2) DEFAULT 0.00,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `programa_lealtad`
--

CREATE TABLE `programa_lealtad` (
  `id` bigint(20) NOT NULL,
  `cliente_id` bigint(20) NOT NULL,
  `puntos_acumulados` int(11) DEFAULT 0,
  `puntos_canjeados` int(11) DEFAULT 0,
  `puntos_disponibles` int(11) GENERATED ALWAYS AS (`puntos_acumulados` - `puntos_canjeados`) STORED,
  `nivel_cliente` enum('BRONCE','PLATA','ORO','PLATINO') DEFAULT 'BRONCE',
  `fecha_ultimo_movimiento` timestamp NOT NULL DEFAULT current_timestamp(),
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `promociones`
--

CREATE TABLE `promociones` (
  `id` bigint(20) NOT NULL,
  `codigo` varchar(50) NOT NULL,
  `nombre` varchar(200) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `tipo_promocion` enum('DESCUENTO_PORCENTAJE','DESCUENTO_MONTO','2X1','3X2','ENVIO_GRATIS','REGALO') NOT NULL,
  `valor_descuento` decimal(10,2) DEFAULT NULL,
  `porcentaje_descuento` decimal(5,2) DEFAULT NULL,
  `monto_minimo_compra` decimal(10,2) DEFAULT NULL,
  `cantidad_maxima_usos` int(11) DEFAULT NULL,
  `usos_por_cliente` int(11) DEFAULT 1,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `aplica_a` enum('TODOS','PRODUCTOS','CATEGORIAS','CLIENTES') DEFAULT 'TODOS',
  `creado_por` bigint(20) DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `promociones_categorias`
--

CREATE TABLE `promociones_categorias` (
  `id` bigint(20) NOT NULL,
  `promocion_id` bigint(20) NOT NULL,
  `categoria_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `promociones_productos`
--

CREATE TABLE `promociones_productos` (
  `id` bigint(20) NOT NULL,
  `promocion_id` bigint(20) NOT NULL,
  `producto_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `promociones_uso`
--

CREATE TABLE `promociones_uso` (
  `id` bigint(20) NOT NULL,
  `promocion_id` bigint(20) NOT NULL,
  `venta_id` bigint(20) NOT NULL,
  `cliente_id` bigint(20) NOT NULL,
  `monto_descuento` decimal(10,2) NOT NULL,
  `fecha_uso` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

CREATE TABLE `proveedores` (
  `id` bigint(20) NOT NULL,
  `codigo_proveedor` varchar(20) DEFAULT NULL,
  `razon_social` varchar(200) NOT NULL,
  `nombre_comercial` varchar(200) DEFAULT NULL,
  `tipo_documento` enum('RUC','DNI','PASAPORTE') DEFAULT 'RUC',
  `numero_documento` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `distrito_id` bigint(20) DEFAULT NULL,
  `contacto_principal` varchar(100) DEFAULT NULL,
  `telefono_contacto` varchar(20) DEFAULT NULL,
  `email_contacto` varchar(100) DEFAULT NULL,
  `condiciones_pago` varchar(200) DEFAULT NULL,
  `tiempo_entrega_dias` int(11) DEFAULT NULL,
  `calificacion` decimal(3,2) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `notas` text DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `provincias`
--

CREATE TABLE `provincias` (
  `id` bigint(20) NOT NULL,
  `departamento_id` bigint(20) NOT NULL,
  `codigo` varchar(10) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `provincias`
--

INSERT INTO `provincias` (`id`, `departamento_id`, `codigo`, `nombre`, `activo`) VALUES
(1, 1, 'MAY', 'Maynas', 1),
(2, 1, 'UCY', 'Ucayali', 1),
(3, 1, 'REQ', 'Requena', 1),
(4, 1, 'LOR', 'Loreto', 1),
(5, 1, 'MDO', 'Mariscal Ramón Castilla', 1),
(6, 1, 'DAT', 'Datem del Marañón', 1),
(7, 1, 'PUT', 'Putumayo', 1),
(8, 1, 'ALT', 'Alto Amazonas', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `id` bigint(20) NOT NULL,
  `codigo` varchar(30) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `nivel_acceso` int(11) DEFAULT 1,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`id`, `codigo`, `nombre`, `descripcion`, `nivel_acceso`, `activo`, `fecha_creacion`) VALUES
(1, 'SUPER_ADMIN', 'Super Administrador', 'Acceso total al sistema', 10, 1, '2025-07-17 23:28:34'),
(2, 'ADMIN', 'Administrador', 'Administrador general', 8, 1, '2025-07-17 23:28:34'),
(3, 'MANAGER', 'Gerente', 'Gerente de tienda', 6, 1, '2025-07-17 23:28:34'),
(4, 'VENDEDOR', 'Vendedor', 'Personal de ventas', 4, 1, '2025-07-17 23:28:34'),
(5, 'CAJERO', 'Cajero', 'Personal de caja', 3, 1, '2025-07-17 23:28:34'),
(6, 'INVENTARIO', 'Inventario', 'Personal de almacén', 2, 1, '2025-07-17 23:28:34');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles_permisos`
--

CREATE TABLE `roles_permisos` (
  `id` bigint(20) NOT NULL,
  `rol_id` bigint(20) NOT NULL,
  `permiso_id` bigint(20) NOT NULL,
  `concedido` tinyint(1) DEFAULT 1,
  `fecha_asignacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `asignado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `roles_permisos`
--

INSERT INTO `roles_permisos` (`id`, `rol_id`, `permiso_id`, `concedido`, `fecha_asignacion`, `asignado_por`) VALUES
(1, 1, 10, 1, '2025-07-17 23:28:34', NULL),
(2, 1, 11, 1, '2025-07-17 23:28:34', NULL),
(3, 1, 9, 1, '2025-07-17 23:28:34', NULL),
(4, 1, 17, 1, '2025-07-17 23:28:34', NULL),
(5, 1, 16, 1, '2025-07-17 23:28:34', NULL),
(6, 1, 13, 1, '2025-07-17 23:28:34', NULL),
(7, 1, 12, 1, '2025-07-17 23:28:34', NULL),
(8, 1, 2, 1, '2025-07-17 23:28:34', NULL),
(9, 1, 3, 1, '2025-07-17 23:28:34', NULL),
(10, 1, 4, 1, '2025-07-17 23:28:34', NULL),
(11, 1, 1, 1, '2025-07-17 23:28:34', NULL),
(12, 1, 15, 1, '2025-07-17 23:28:34', NULL),
(13, 1, 14, 1, '2025-07-17 23:28:34', NULL),
(14, 1, 8, 1, '2025-07-17 23:28:34', NULL),
(15, 1, 6, 1, '2025-07-17 23:28:34', NULL),
(16, 1, 7, 1, '2025-07-17 23:28:34', NULL),
(17, 1, 5, 1, '2025-07-17 23:28:34', NULL),
(32, 4, 1, 1, '2025-07-17 23:28:34', NULL),
(33, 4, 5, 1, '2025-07-17 23:28:34', NULL),
(34, 4, 6, 1, '2025-07-17 23:28:34', NULL),
(35, 4, 9, 1, '2025-07-17 23:28:34', NULL),
(36, 4, 10, 1, '2025-07-17 23:28:34', NULL),
(37, 4, 11, 1, '2025-07-17 23:28:34', NULL),
(38, 4, 12, 1, '2025-07-17 23:28:34', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sesiones_usuario`
--

CREATE TABLE `sesiones_usuario` (
  `id` bigint(20) NOT NULL,
  `usuario_id` bigint(20) NOT NULL,
  `token_sesion` varchar(255) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  `fecha_inicio` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_ultimo_acceso` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `fecha_expiracion` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `activa` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tallas`
--

CREATE TABLE `tallas` (
  `id` bigint(20) NOT NULL,
  `codigo` varchar(10) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `categoria_talla` enum('ROPA_MUJER','ROPA_HOMBRE','CALZADO_MUJER','CALZADO_HOMBRE','ACCESORIOS','INFANTIL') NOT NULL,
  `orden_visualizacion` int(11) DEFAULT 0,
  `medidas_cm` varchar(200) DEFAULT NULL,
  `equivalencia_internacional` varchar(50) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tallas`
--

INSERT INTO `tallas` (`id`, `codigo`, `nombre`, `descripcion`, `categoria_talla`, `orden_visualizacion`, `medidas_cm`, `equivalencia_internacional`, `activo`, `fecha_creacion`, `fecha_actualizacion`, `creado_por`, `modificado_por`) VALUES
(1, 'XS_M', 'XS', 'Extra Small Mujer', 'ROPA_MUJER', 1, 'Busto: 78-82cm, Cintura: 58-62cm, Cadera: 86-90cm', 'XS', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(2, 'S_M', 'S', 'Small Mujer', 'ROPA_MUJER', 2, 'Busto: 82-86cm, Cintura: 62-66cm, Cadera: 90-94cm', 'S', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(3, 'M_M', 'M', 'Medium Mujer', 'ROPA_MUJER', 3, 'Busto: 86-90cm, Cintura: 66-70cm, Cadera: 94-98cm', 'M', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(4, 'L_M', 'L', 'Large Mujer', 'ROPA_MUJER', 4, 'Busto: 90-94cm, Cintura: 70-74cm, Cadera: 98-102cm', 'L', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(5, 'XL_M', 'XL', 'Extra Large Mujer', 'ROPA_MUJER', 5, 'Busto: 94-98cm, Cintura: 74-78cm, Cadera: 102-106cm', 'XL', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(6, 'XXL_M', 'XXL', 'Double Extra Large Mujer', 'ROPA_MUJER', 6, 'Busto: 98-102cm, Cintura: 78-82cm, Cadera: 106-110cm', 'XXL', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(7, 'S_H', 'S', 'Small Hombre', 'ROPA_HOMBRE', 10, 'Pecho: 88-92cm, Cintura: 76-80cm', 'S', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(8, 'M_H', 'M', 'Medium Hombre', 'ROPA_HOMBRE', 11, 'Pecho: 92-96cm, Cintura: 80-84cm', 'M', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(9, 'L_H', 'L', 'Large Hombre', 'ROPA_HOMBRE', 12, 'Pecho: 96-100cm, Cintura: 84-88cm', 'L', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(10, 'XL_H', 'XL', 'Extra Large Hombre', 'ROPA_HOMBRE', 13, 'Pecho: 100-104cm, Cintura: 88-92cm', 'XL', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(11, 'XXL_H', 'XXL', 'Double Extra Large Hombre', 'ROPA_HOMBRE', 14, 'Pecho: 104-108cm, Cintura: 92-96cm', 'XXL', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(12, '35_M', '35', 'Talla 35 Mujer', 'CALZADO_MUJER', 20, 'Longitud: 22.5cm', '5 US', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(13, '36_M', '36', 'Talla 36 Mujer', 'CALZADO_MUJER', 21, 'Longitud: 23cm', '5.5 US', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(14, '37_M', '37', 'Talla 37 Mujer', 'CALZADO_MUJER', 22, 'Longitud: 23.5cm', '6 US', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(15, '38_M', '38', 'Talla 38 Mujer', 'CALZADO_MUJER', 23, 'Longitud: 24cm', '6.5 US', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(16, '39_M', '39', 'Talla 39 Mujer', 'CALZADO_MUJER', 24, 'Longitud: 24.5cm', '7 US', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(17, '40_M', '40', 'Talla 40 Mujer', 'CALZADO_MUJER', 25, 'Longitud: 25cm', '7.5 US', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(18, '39_H', '39', 'Talla 39 Hombre', 'CALZADO_HOMBRE', 30, 'Longitud: 24.5cm', '7 US', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(19, '40_H', '40', 'Talla 40 Hombre', 'CALZADO_HOMBRE', 31, 'Longitud: 25cm', '7.5 US', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(20, '41_H', '41', 'Talla 41 Hombre', 'CALZADO_HOMBRE', 32, 'Longitud: 25.5cm', '8 US', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(21, '42_H', '42', 'Talla 42 Hombre', 'CALZADO_HOMBRE', 33, 'Longitud: 26cm', '8.5 US', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(22, '43_H', '43', 'Talla 43 Hombre', 'CALZADO_HOMBRE', 34, 'Longitud: 26.5cm', '9 US', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL),
(23, '44_H', '44', 'Talla 44 Hombre', 'CALZADO_HOMBRE', 35, 'Longitud: 27cm', '9.5 US', 1, '2025-07-17 23:28:34', '2025-07-18 17:21:43', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tareas_seguimiento`
--

CREATE TABLE `tareas_seguimiento` (
  `id` bigint(20) NOT NULL,
  `cliente_id` bigint(20) DEFAULT NULL,
  `interaccion_id` bigint(20) DEFAULT NULL,
  `tipo_tarea` enum('LLAMADA','EMAIL','VISITA','COTIZACION','PROMOCION','OTROS') NOT NULL,
  `titulo` varchar(200) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_programada` datetime NOT NULL,
  `fecha_completada` timestamp NULL DEFAULT NULL,
  `prioridad` enum('BAJA','MEDIA','ALTA','URGENTE') DEFAULT 'MEDIA',
  `estado` enum('PENDIENTE','EN_PROCESO','COMPLETADA','CANCELADA') DEFAULT 'PENDIENTE',
  `asignado_a` bigint(20) NOT NULL,
  `observaciones` text DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_gasto`
--

CREATE TABLE `tipos_gasto` (
  `id` bigint(20) NOT NULL,
  `codigo` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `categoria` enum('OPERATIVO','ADMINISTRATIVO','MARKETING','MANTENIMIENTO','SERVICIOS','OTROS') DEFAULT 'OPERATIVO',
  `requiere_autorizacion` tinyint(1) DEFAULT 0,
  `monto_maximo_sin_autorizacion` decimal(10,2) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tipos_gasto`
--

INSERT INTO `tipos_gasto` (`id`, `codigo`, `nombre`, `descripcion`, `categoria`, `requiere_autorizacion`, `monto_maximo_sin_autorizacion`, `activo`, `fecha_creacion`) VALUES
(1, 'ALQUILER', 'Alquiler Local', 'Pago de alquiler del local comercial', 'OPERATIVO', 1, 0.00, 1, '2025-07-17 23:28:34'),
(2, 'SERVICIOS', 'Servicios Básicos', 'Luz, agua, internet, teléfono', 'OPERATIVO', 0, 500.00, 1, '2025-07-17 23:28:34'),
(3, 'MARKETING', 'Marketing y Publicidad', 'Gastos en promoción y publicidad', 'MARKETING', 1, 200.00, 1, '2025-07-17 23:28:34'),
(4, 'MANTENIMIENTO', 'Mantenimiento', 'Reparaciones y mantenimiento', 'MANTENIMIENTO', 0, 300.00, 1, '2025-07-17 23:28:34'),
(5, 'SUMINISTROS', 'Suministros de Oficina', 'Papelería, bolsas, etiquetas', 'ADMINISTRATIVO', 0, 100.00, 1, '2025-07-17 23:28:34'),
(6, 'TRANSPORTE', 'Transporte', 'Gastos de movilidad y envíos', 'OPERATIVO', 0, 150.00, 1, '2025-07-17 23:28:34');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transacciones_puntos`
--

CREATE TABLE `transacciones_puntos` (
  `id` bigint(20) NOT NULL,
  `cliente_id` bigint(20) NOT NULL,
  `tipo_transaccion` enum('GANANCIA','CANJE','EXPIRACION','AJUSTE','BONO') NOT NULL,
  `puntos` int(11) NOT NULL,
  `descripcion` varchar(500) DEFAULT NULL,
  `venta_id` bigint(20) DEFAULT NULL,
  `fecha_transaccion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_expiracion` date DEFAULT NULL,
  `usuario_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transferencias_inventario`
--

CREATE TABLE `transferencias_inventario` (
  `id` bigint(20) NOT NULL,
  `numero_transferencia` varchar(20) NOT NULL,
  `ubicacion_origen` varchar(100) NOT NULL,
  `ubicacion_destino` varchar(100) NOT NULL,
  `fecha_transferencia` date NOT NULL,
  `estado` enum('PENDIENTE','EN_TRANSITO','RECIBIDA','CANCELADA') DEFAULT 'PENDIENTE',
  `observaciones` text DEFAULT NULL,
  `autorizado_por` bigint(20) DEFAULT NULL,
  `recibido_por` bigint(20) DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidades_medida`
--

CREATE TABLE `unidades_medida` (
  `id` bigint(20) NOT NULL,
  `codigo` varchar(10) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `simbolo` varchar(10) DEFAULT NULL,
  `tipo` enum('PESO','LONGITUD','VOLUMEN','UNIDAD','TIEMPO') DEFAULT 'UNIDAD',
  `factor_conversion` decimal(10,6) DEFAULT 1.000000,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `unidades_medida`
--

INSERT INTO `unidades_medida` (`id`, `codigo`, `nombre`, `simbolo`, `tipo`, `factor_conversion`, `activo`, `fecha_creacion`, `fecha_actualizacion`, `creado_por`, `modificado_por`) VALUES
(1, 'UND', 'Unidad', 'und', 'UNIDAD', 1.000000, 1, '2025-07-18 17:21:32', '2025-07-18 17:21:32', NULL, NULL),
(2, 'PAR', 'Par', 'par', 'UNIDAD', 1.000000, 1, '2025-07-18 17:21:32', '2025-07-18 17:21:32', NULL, NULL),
(3, 'DOC', 'Docena', 'doc', 'UNIDAD', 1.000000, 1, '2025-07-18 17:21:32', '2025-07-18 17:21:32', NULL, NULL),
(4, 'KG', 'Kilogramo', 'kg', 'PESO', 1.000000, 1, '2025-07-18 17:21:32', '2025-07-18 17:21:32', NULL, NULL),
(5, 'GR', 'Gramo', 'g', 'PESO', 1.000000, 1, '2025-07-18 17:21:32', '2025-07-18 17:21:32', NULL, NULL),
(6, 'MT', 'Metro', 'm', 'LONGITUD', 1.000000, 1, '2025-07-18 17:21:32', '2025-07-18 17:21:32', NULL, NULL),
(7, 'CM', 'Centímetro', 'cm', 'LONGITUD', 1.000000, 1, '2025-07-18 17:21:32', '2025-07-18 17:21:32', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` bigint(20) NOT NULL,
  `codigo_empleado` varchar(20) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `rol_id` bigint(20) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `fecha_ingreso` date DEFAULT NULL,
  `salario_base` decimal(10,2) DEFAULT NULL,
  `comision_porcentaje` decimal(5,2) DEFAULT 0.00,
  `foto_perfil` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `ultimo_acceso` timestamp NULL DEFAULT NULL,
  `intentos_login_fallidos` int(11) DEFAULT 0,
  `bloqueado_hasta` timestamp NULL DEFAULT NULL,
  `creado_por` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `codigo_empleado`, `nombre`, `apellido`, `email`, `password`, `rol_id`, `telefono`, `direccion`, `fecha_nacimiento`, `fecha_ingreso`, `salario_base`, `comision_porcentaje`, `foto_perfil`, `activo`, `fecha_creacion`, `fecha_actualizacion`, `ultimo_acceso`, `intentos_login_fallidos`, `bloqueado_hasta`, `creado_por`) VALUES
(1, 'EMP001', 'Super', 'Administrador', 'admin@dpattymoda.com', '$2a$10$UVF7iyQYdCWkqzXHFm77EOxpNwmUg1VqISzollJhWg8jlpVUD.Huu', 1, NULL, NULL, NULL, NULL, NULL, 0.00, NULL, 1, '2025-07-17 23:28:34', '2025-07-17 23:28:34', NULL, 0, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `id` bigint(20) NOT NULL,
  `numero_venta` varchar(20) NOT NULL,
  `cliente_id` bigint(20) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `subtotal` decimal(12,2) DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL,
  `estado` enum('PENDIENTE','PAGADA','PARCIALMENTE_PAGADA','ANULADA','DEVUELTA') DEFAULT 'PENDIENTE',
  `canal_venta_id` bigint(20) DEFAULT NULL,
  `vendedor_id` bigint(20) DEFAULT NULL,
  `cajero_id` bigint(20) DEFAULT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `notas_internas` text DEFAULT NULL,
  `cantidad_items` int(11) DEFAULT 0,
  `peso_total` decimal(8,3) DEFAULT NULL,
  `comision_vendedor` decimal(10,2) DEFAULT 0.00,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creado_por` bigint(20) DEFAULT NULL,
  `modificado_por` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Disparadores `ventas`
--
DELIMITER $$
CREATE TRIGGER `after_update_venta_pagada` AFTER UPDATE ON `ventas` FOR EACH ROW BEGIN
    IF OLD.estado != 'PAGADA' AND NEW.estado = 'PAGADA' THEN
        UPDATE clientes_comercial 
        SET 
            total_compras = total_compras + NEW.total,
            cantidad_compras = cantidad_compras + 1,
            ultima_compra = NEW.fecha
        WHERE cliente_id = NEW.cliente_id;
        
        -- Actualizar puntos de lealtad (1 punto por cada sol gastado)
        INSERT INTO transacciones_puntos (cliente_id, tipo_transaccion, puntos, descripcion, venta_id)
        VALUES (NEW.cliente_id, 'GANANCIA', FLOOR(NEW.total), CONCAT('Compra venta ', NEW.numero_venta), NEW.id)
        ON DUPLICATE KEY UPDATE puntos = puntos;
        
        UPDATE programa_lealtad 
        SET puntos_acumulados = puntos_acumulados + FLOOR(NEW.total),
            fecha_ultimo_movimiento = CURRENT_TIMESTAMP
        WHERE cliente_id = NEW.cliente_id;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_venta` BEFORE INSERT ON `ventas` FOR EACH ROW BEGIN
    IF NEW.numero_venta IS NULL OR NEW.numero_venta = '' THEN
        SET NEW.numero_venta = CONCAT('V', YEAR(NOW()), LPAD(
            COALESCE(
                (SELECT MAX(CAST(SUBSTRING(numero_venta, 6) AS UNSIGNED))
                 FROM ventas 
                 WHERE numero_venta LIKE CONCAT('V', YEAR(NOW()), '%')), 0
            ) + 1, 6, '0'
        ));
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas_descuentos`
--

CREATE TABLE `ventas_descuentos` (
  `id` bigint(20) NOT NULL,
  `venta_id` bigint(20) NOT NULL,
  `tipo_descuento` enum('PORCENTAJE','MONTO_FIJO','PROMOCION','CLIENTE_VIP') NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `porcentaje` decimal(5,2) DEFAULT NULL,
  `monto` decimal(10,2) NOT NULL,
  `promocion_id` bigint(20) DEFAULT NULL,
  `aplicado_por` bigint(20) DEFAULT NULL,
  `fecha_aplicacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas_entrega`
--

CREATE TABLE `ventas_entrega` (
  `id` bigint(20) NOT NULL,
  `venta_id` bigint(20) NOT NULL,
  `tipo_entrega` enum('RECOJO_TIENDA','DELIVERY','ENVIO_COURIER','ENVIO_POSTAL') DEFAULT 'RECOJO_TIENDA',
  `direccion_entrega` text DEFAULT NULL,
  `distrito_entrega_id` bigint(20) DEFAULT NULL,
  `fecha_programada` date DEFAULT NULL,
  `fecha_entrega_real` timestamp NULL DEFAULT NULL,
  `costo_envio` decimal(10,2) DEFAULT 0.00,
  `transportista` varchar(100) DEFAULT NULL,
  `numero_guia` varchar(50) DEFAULT NULL,
  `estado_entrega` enum('PENDIENTE','EN_TRANSITO','ENTREGADO','DEVUELTO','CANCELADO') DEFAULT 'PENDIENTE',
  `observaciones_entrega` text DEFAULT NULL,
  `recibido_por` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas_facturacion`
--

CREATE TABLE `ventas_facturacion` (
  `id` bigint(20) NOT NULL,
  `venta_id` bigint(20) NOT NULL,
  `tipo_comprobante` enum('BOLETA','FACTURA','NOTA_VENTA','TICKET') DEFAULT 'BOLETA',
  `serie_comprobante` varchar(10) DEFAULT NULL,
  `numero_comprobante` varchar(20) DEFAULT NULL,
  `fecha_emision` date DEFAULT NULL,
  `moneda` varchar(3) DEFAULT 'PEN',
  `tipo_cambio` decimal(8,4) DEFAULT 1.0000,
  `direccion_facturacion` text DEFAULT NULL,
  `datos_adicionales` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`datos_adicionales`)),
  `hash_comprobante` varchar(255) DEFAULT NULL,
  `enviado_sunat` tinyint(1) DEFAULT 0,
  `fecha_envio_sunat` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_clientes_estadisticas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_clientes_estadisticas` (
`id` bigint(20)
,`codigo_cliente` varchar(20)
,`nombre` varchar(100)
,`apellido` varchar(100)
,`numero_documento` varchar(20)
,`tipo_documento` enum('DNI','RUC','PASAPORTE','CARNET_EXTRANJERIA')
,`tipo_cliente` enum('REGULAR','VIP','MAYORISTA','MINORISTA','CORPORATIVO')
,`total_compras` decimal(12,2)
,`cantidad_compras` int(11)
,`ultima_compra` timestamp
,`limite_credito` decimal(10,2)
,`descuento_personalizado` decimal(5,2)
,`puntos_disponibles` int(11)
,`nivel_cliente` enum('BRONCE','PLATA','ORO','PLATINO')
,`activo` tinyint(1)
,`categoria_cliente` varchar(7)
,`ticket_promedio` decimal(16,6)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_productos_completa`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_productos_completa` (
`id` bigint(20)
,`codigo_producto` varchar(50)
,`nombre` varchar(255)
,`sku` varchar(100)
,`descripcion` text
,`descripcion_corta` varchar(500)
,`categoria_nombre` varchar(100)
,`categoria_id` bigint(20)
,`marca_nombre` varchar(100)
,`marca_id` bigint(20)
,`precio` decimal(10,2)
,`precio_oferta` decimal(10,2)
,`costo` decimal(10,2)
,`margen_porcentaje` decimal(5,2)
,`stock` int(11)
,`stock_minimo` int(11)
,`stock_maximo` int(11)
,`stock_disponible` int(11)
,`imagen_principal` varchar(255)
,`requiere_talla` tinyint(1)
,`requiere_color` tinyint(1)
,`destacado` tinyint(1)
,`activo` tinyint(1)
,`fecha_creacion` timestamp
,`estado_stock` varchar(10)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_ventas_completa`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_ventas_completa` (
`id` bigint(20)
,`numero_venta` varchar(20)
,`fecha` timestamp
,`subtotal` decimal(12,2)
,`total` decimal(12,2)
,`estado` enum('PENDIENTE','PAGADA','PARCIALMENTE_PAGADA','ANULADA','DEVUELTA')
,`tipo_comprobante` enum('BOLETA','FACTURA','NOTA_VENTA','TICKET')
,`serie_comprobante` varchar(10)
,`numero_comprobante` varchar(20)
,`canal_venta` varchar(50)
,`cliente_nombre` varchar(201)
,`cliente_documento` varchar(20)
,`vendedor_nombre` varchar(201)
,`cantidad_items` int(11)
,`comision_vendedor` decimal(10,2)
,`estado_entrega` enum('PENDIENTE','EN_TRANSITO','ENTREGADO','DEVUELTO','CANCELADO')
,`fecha_entrega_real` timestamp
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_clientes_estadisticas`
--
DROP TABLE IF EXISTS `vista_clientes_estadisticas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_clientes_estadisticas`  AS SELECT `c`.`id` AS `id`, `c`.`codigo_cliente` AS `codigo_cliente`, `c`.`nombre` AS `nombre`, `c`.`apellido` AS `apellido`, `c`.`numero_documento` AS `numero_documento`, `c`.`tipo_documento` AS `tipo_documento`, `cc`.`tipo_cliente` AS `tipo_cliente`, `cc`.`total_compras` AS `total_compras`, `cc`.`cantidad_compras` AS `cantidad_compras`, `cc`.`ultima_compra` AS `ultima_compra`, `cc`.`limite_credito` AS `limite_credito`, `cc`.`descuento_personalizado` AS `descuento_personalizado`, `pl`.`puntos_disponibles` AS `puntos_disponibles`, `pl`.`nivel_cliente` AS `nivel_cliente`, `c`.`activo` AS `activo`, CASE WHEN `cc`.`total_compras` >= 5000 THEN 'VIP' WHEN `cc`.`total_compras` >= 2000 THEN 'PREMIUM' WHEN `cc`.`total_compras` >= 500 THEN 'REGULAR' ELSE 'NUEVO' END AS `categoria_cliente`, coalesce(`cc`.`total_compras` / nullif(`cc`.`cantidad_compras`,0),0) AS `ticket_promedio` FROM ((`clientes` `c` left join `clientes_comercial` `cc` on(`c`.`id` = `cc`.`cliente_id`)) left join `programa_lealtad` `pl` on(`c`.`id` = `pl`.`cliente_id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_productos_completa`
--
DROP TABLE IF EXISTS `vista_productos_completa`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_productos_completa`  AS SELECT `p`.`id` AS `id`, `p`.`codigo_producto` AS `codigo_producto`, `p`.`nombre` AS `nombre`, `p`.`sku` AS `sku`, `p`.`descripcion` AS `descripcion`, `p`.`descripcion_corta` AS `descripcion_corta`, `c`.`nombre` AS `categoria_nombre`, `c`.`id` AS `categoria_id`, `m`.`nombre` AS `marca_nombre`, `m`.`id` AS `marca_id`, `pp`.`precio_venta` AS `precio`, `pp`.`precio_oferta` AS `precio_oferta`, `pp`.`costo` AS `costo`, `pp`.`margen_porcentaje` AS `margen_porcentaje`, `pi`.`stock_actual` AS `stock`, `pi`.`stock_minimo` AS `stock_minimo`, `pi`.`stock_maximo` AS `stock_maximo`, `pi`.`stock_disponible` AS `stock_disponible`, `p`.`imagen_principal` AS `imagen_principal`, `p`.`requiere_talla` AS `requiere_talla`, `p`.`requiere_color` AS `requiere_color`, `p`.`destacado` AS `destacado`, `p`.`activo` AS `activo`, `p`.`fecha_creacion` AS `fecha_creacion`, CASE WHEN `pi`.`stock_actual` <= 0 THEN 'SIN_STOCK' WHEN `pi`.`stock_actual` <= `pi`.`stock_minimo` THEN 'STOCK_BAJO' ELSE 'STOCK_OK' END AS `estado_stock` FROM ((((`productos` `p` left join `categorias` `c` on(`p`.`categoria_id` = `c`.`id`)) left join `marcas` `m` on(`p`.`marca_id` = `m`.`id`)) left join `productos_precios` `pp` on(`p`.`id` = `pp`.`producto_id` and `pp`.`activo` = 1 and (`pp`.`fecha_fin` is null or `pp`.`fecha_fin` >= curdate()))) left join `productos_inventario` `pi` on(`p`.`id` = `pi`.`producto_id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_ventas_completa`
--
DROP TABLE IF EXISTS `vista_ventas_completa`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_ventas_completa`  AS SELECT `v`.`id` AS `id`, `v`.`numero_venta` AS `numero_venta`, `v`.`fecha` AS `fecha`, `v`.`subtotal` AS `subtotal`, `v`.`total` AS `total`, `v`.`estado` AS `estado`, `vf`.`tipo_comprobante` AS `tipo_comprobante`, `vf`.`serie_comprobante` AS `serie_comprobante`, `vf`.`numero_comprobante` AS `numero_comprobante`, `cv`.`nombre` AS `canal_venta`, concat(`c`.`nombre`,' ',coalesce(`c`.`apellido`,'')) AS `cliente_nombre`, `c`.`numero_documento` AS `cliente_documento`, concat(`u`.`nombre`,' ',coalesce(`u`.`apellido`,'')) AS `vendedor_nombre`, `v`.`cantidad_items` AS `cantidad_items`, `v`.`comision_vendedor` AS `comision_vendedor`, `ve`.`estado_entrega` AS `estado_entrega`, `ve`.`fecha_entrega_real` AS `fecha_entrega_real` FROM (((((`ventas` `v` left join `clientes` `c` on(`v`.`cliente_id` = `c`.`id`)) left join `usuarios` `u` on(`v`.`vendedor_id` = `u`.`id`)) left join `canales_venta` `cv` on(`v`.`canal_venta_id` = `cv`.`id`)) left join `ventas_facturacion` `vf` on(`v`.`id` = `vf`.`venta_id`)) left join `ventas_entrega` `ve` on(`v`.`id` = `ve`.`venta_id`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `arqueos_caja`
--
ALTER TABLE `arqueos_caja`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_apertura` (`usuario_apertura`),
  ADD KEY `usuario_cierre` (`usuario_cierre`),
  ADD KEY `idx_arqueos_caja` (`caja_id`),
  ADD KEY `idx_arqueos_fecha` (`fecha_arqueo`);

--
-- Indices de la tabla `auditoria_logs`
--
ALTER TABLE `auditoria_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_auditoria_tabla` (`tabla`),
  ADD KEY `idx_auditoria_registro` (`registro_id`),
  ADD KEY `idx_auditoria_fecha` (`fecha_accion`),
  ADD KEY `idx_auditoria_usuario` (`usuario_id`),
  ADD KEY `fk_auditoria_logs_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `cajas`
--
ALTER TABLE `cajas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD KEY `idx_cajas_responsable` (`responsable_id`),
  ADD KEY `idx_cajas_activo` (`activo`),
  ADD KEY `fk_cajas_creado_por` (`creado_por`),
  ADD KEY `fk_cajas_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `canales_venta`
--
ALTER TABLE `canales_venta`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD KEY `fk_canales_venta_creado_por` (`creado_por`),
  ADD KEY `fk_canales_venta_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD KEY `creado_por` (`creado_por`),
  ADD KEY `modificado_por` (`modificado_por`),
  ADD KEY `idx_categorias_padre` (`categoria_padre_id`),
  ADD KEY `idx_categorias_activo` (`activo`),
  ADD KEY `idx_categorias_orden` (`orden`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo_cliente` (`codigo_cliente`),
  ADD KEY `creado_por` (`creado_por`),
  ADD KEY `modificado_por` (`modificado_por`),
  ADD KEY `idx_clientes_documento` (`tipo_documento`,`numero_documento`),
  ADD KEY `idx_clientes_activo` (`activo`),
  ADD KEY `idx_clientes_nombre` (`nombre`,`apellido`);

--
-- Indices de la tabla `clientes_comercial`
--
ALTER TABLE `clientes_comercial`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cliente_id` (`cliente_id`),
  ADD KEY `vendedor_asignado_id` (`vendedor_asignado_id`),
  ADD KEY `idx_comercial_tipo` (`tipo_cliente`),
  ADD KEY `idx_comercial_total` (`total_compras`);

--
-- Indices de la tabla `clientes_contacto`
--
ALTER TABLE `clientes_contacto`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_contacto_cliente` (`cliente_id`),
  ADD KEY `idx_contacto_tipo` (`tipo_contacto`);

--
-- Indices de la tabla `clientes_direcciones`
--
ALTER TABLE `clientes_direcciones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_direcciones_cliente` (`cliente_id`),
  ADD KEY `idx_direcciones_distrito` (`distrito_id`);

--
-- Indices de la tabla `clientes_preferencias`
--
ALTER TABLE `clientes_preferencias`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cliente_id` (`cliente_id`),
  ADD KEY `canal_preferido_id` (`canal_preferido_id`),
  ADD KEY `talla_preferida_id` (`talla_preferida_id`),
  ADD KEY `color_preferido_id` (`color_preferido_id`),
  ADD KEY `marca_preferida_id` (`marca_preferida_id`);

--
-- Indices de la tabla `colores`
--
ALTER TABLE `colores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD KEY `idx_colores_familia` (`familia_color`),
  ADD KEY `idx_colores_activo` (`activo`),
  ADD KEY `fk_colores_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `compras`
--
ALTER TABLE `compras`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `numero_compra` (`numero_compra`),
  ADD KEY `creado_por` (`creado_por`),
  ADD KEY `idx_compras_proveedor` (`proveedor_id`),
  ADD KEY `idx_compras_fecha` (`fecha_compra`),
  ADD KEY `idx_compras_estado` (`estado`),
  ADD KEY `fk_compras_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `configuracion_impuestos`
--
ALTER TABLE `configuracion_impuestos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD KEY `creado_por` (`creado_por`),
  ADD KEY `idx_impuestos_activo` (`activo`),
  ADD KEY `idx_impuestos_por_defecto` (`aplicar_por_defecto`);

--
-- Indices de la tabla `configuracion_tienda`
--
ALTER TABLE `configuracion_tienda`
  ADD PRIMARY KEY (`id`),
  ADD KEY `distrito_id` (`distrito_id`),
  ADD KEY `fk_configuracion_tienda_creado_por` (`creado_por`),
  ADD KEY `fk_configuracion_tienda_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `cotizaciones`
--
ALTER TABLE `cotizaciones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `numero_cotizacion` (`numero_cotizacion`),
  ADD KEY `vendedor_id` (`vendedor_id`),
  ADD KEY `venta_id` (`venta_id`),
  ADD KEY `creado_por` (`creado_por`),
  ADD KEY `idx_cotizaciones_cliente` (`cliente_id`),
  ADD KEY `idx_cotizaciones_fecha` (`fecha_cotizacion`),
  ADD KEY `idx_cotizaciones_estado` (`estado`),
  ADD KEY `fk_cotizaciones_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `departamentos`
--
ALTER TABLE `departamentos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_departamentos_pais` (`pais_id`);

--
-- Indices de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_detalle_compra` (`compra_id`),
  ADD KEY `idx_detalle_producto` (`producto_id`),
  ADD KEY `fk_detalle_compra_creado_por` (`creado_por`),
  ADD KEY `fk_detalle_compra_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `detalle_cotizacion`
--
ALTER TABLE `detalle_cotizacion`
  ADD PRIMARY KEY (`id`),
  ADD KEY `talla_id` (`talla_id`),
  ADD KEY `color_id` (`color_id`),
  ADD KEY `idx_detalle_cotizacion` (`cotizacion_id`),
  ADD KEY `idx_detalle_cotizacion_producto` (`producto_id`),
  ADD KEY `fk_detalle_cotizacion_creado_por` (`creado_por`),
  ADD KEY `fk_detalle_cotizacion_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `detalle_devolucion`
--
ALTER TABLE `detalle_devolucion`
  ADD PRIMARY KEY (`id`),
  ADD KEY `detalle_venta_id` (`detalle_venta_id`),
  ADD KEY `idx_detalle_devolucion` (`devolucion_id`),
  ADD KEY `fk_detalle_devolucion_creado_por` (`creado_por`),
  ADD KEY `fk_detalle_devolucion_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `detalle_transferencia`
--
ALTER TABLE `detalle_transferencia`
  ADD PRIMARY KEY (`id`),
  ADD KEY `producto_id` (`producto_id`),
  ADD KEY `idx_detalle_transferencia` (`transferencia_id`),
  ADD KEY `fk_detalle_transferencia_creado_por` (`creado_por`),
  ADD KEY `fk_detalle_transferencia_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `talla_id` (`talla_id`),
  ADD KEY `color_id` (`color_id`),
  ADD KEY `idx_detalle_venta` (`venta_id`),
  ADD KEY `idx_detalle_producto` (`producto_id`),
  ADD KEY `fk_detalle_venta_creado_por` (`creado_por`),
  ADD KEY `fk_detalle_venta_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `devoluciones`
--
ALTER TABLE `devoluciones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `numero_devolucion` (`numero_devolucion`),
  ADD KEY `autorizado_por` (`autorizado_por`),
  ADD KEY `procesado_por` (`procesado_por`),
  ADD KEY `idx_devoluciones_venta` (`venta_id`),
  ADD KEY `idx_devoluciones_cliente` (`cliente_id`),
  ADD KEY `idx_devoluciones_fecha` (`fecha_devolucion`);

--
-- Indices de la tabla `distritos`
--
ALTER TABLE `distritos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_distritos_provincia` (`provincia_id`);

--
-- Indices de la tabla `gastos`
--
ALTER TABLE `gastos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `numero_gasto` (`numero_gasto`),
  ADD KEY `proveedor_id` (`proveedor_id`),
  ADD KEY `autorizado_por` (`autorizado_por`),
  ADD KEY `pagado_por` (`pagado_por`),
  ADD KEY `caja_id` (`caja_id`),
  ADD KEY `creado_por` (`creado_por`),
  ADD KEY `idx_gastos_tipo` (`tipo_gasto_id`),
  ADD KEY `idx_gastos_fecha` (`fecha_gasto`),
  ADD KEY `idx_gastos_estado` (`estado`);

--
-- Indices de la tabla `horarios_atencion`
--
ALTER TABLE `horarios_atencion`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_dia` (`dia_semana`);

--
-- Indices de la tabla `interacciones_cliente`
--
ALTER TABLE `interacciones_cliente`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `idx_interacciones_cliente` (`cliente_id`),
  ADD KEY `idx_interacciones_fecha` (`fecha_interaccion`),
  ADD KEY `idx_interacciones_estado` (`estado`);

--
-- Indices de la tabla `marcas`
--
ALTER TABLE `marcas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nombre` (`nombre`),
  ADD KEY `idx_marcas_activo` (`activo`),
  ADD KEY `fk_marcas_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `metodos_pago_venta`
--
ALTER TABLE `metodos_pago_venta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_metodos_pago_venta` (`venta_id`),
  ADD KEY `idx_metodos_pago_tipo` (`tipo_pago`);

--
-- Indices de la tabla `movimientos_caja`
--
ALTER TABLE `movimientos_caja`
  ADD PRIMARY KEY (`id`),
  ADD KEY `arqueo_id` (`arqueo_id`),
  ADD KEY `venta_id` (`venta_id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `idx_movimientos_caja` (`caja_id`),
  ADD KEY `idx_movimientos_fecha` (`fecha_movimiento`),
  ADD KEY `idx_movimientos_tipo` (`tipo_movimiento`);

--
-- Indices de la tabla `movimientos_inventario`
--
ALTER TABLE `movimientos_inventario`
  ADD PRIMARY KEY (`id`),
  ADD KEY `venta_id` (`venta_id`),
  ADD KEY `compra_id` (`compra_id`),
  ADD KEY `devolucion_id` (`devolucion_id`),
  ADD KEY `idx_movimientos_producto` (`producto_id`),
  ADD KEY `idx_movimientos_tipo` (`tipo_movimiento`),
  ADD KEY `idx_movimientos_fecha` (`fecha_movimiento`),
  ADD KEY `idx_movimientos_usuario` (`usuario_id`);

--
-- Indices de la tabla `paises`
--
ALTER TABLE `paises`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo_iso` (`codigo_iso`);

--
-- Indices de la tabla `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `idx_token_usuario` (`usuario_id`),
  ADD KEY `idx_token_expiracion` (`fecha_expiracion`);

--
-- Indices de la tabla `permisos`
--
ALTER TABLE `permisos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo_producto` (`codigo_producto`),
  ADD UNIQUE KEY `sku` (`sku`),
  ADD UNIQUE KEY `codigo_barras` (`codigo_barras`),
  ADD KEY `unidad_medida_id` (`unidad_medida_id`),
  ADD KEY `creado_por` (`creado_por`),
  ADD KEY `modificado_por` (`modificado_por`),
  ADD KEY `idx_productos_categoria` (`categoria_id`),
  ADD KEY `idx_productos_marca` (`marca_id`),
  ADD KEY `idx_productos_activo` (`activo`),
  ADD KEY `idx_productos_destacado` (`destacado`),
  ADD KEY `idx_productos_sku` (`sku`);
ALTER TABLE `productos` ADD FULLTEXT KEY `idx_productos_busqueda` (`nombre`,`descripcion`);

--
-- Indices de la tabla `productos_colores`
--
ALTER TABLE `productos_colores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_producto_color` (`producto_id`,`color_id`),
  ADD KEY `idx_productos_colores_producto` (`producto_id`),
  ADD KEY `idx_productos_colores_color` (`color_id`);

--
-- Indices de la tabla `productos_imagenes`
--
ALTER TABLE `productos_imagenes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_imagenes_producto` (`producto_id`),
  ADD KEY `idx_imagenes_principal` (`es_principal`),
  ADD KEY `idx_imagenes_color` (`color_id`);

--
-- Indices de la tabla `productos_inventario`
--
ALTER TABLE `productos_inventario`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `producto_id` (`producto_id`),
  ADD KEY `idx_inventario_stock` (`stock_actual`),
  ADD KEY `idx_inventario_minimo` (`stock_minimo`),
  ADD KEY `idx_inventario_vencimiento` (`fecha_vencimiento`);

--
-- Indices de la tabla `productos_precios`
--
ALTER TABLE `productos_precios`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `idx_precios_producto` (`producto_id`),
  ADD KEY `idx_precios_vigencia` (`fecha_inicio`,`fecha_fin`),
  ADD KEY `idx_precios_activo` (`activo`);

--
-- Indices de la tabla `productos_seo`
--
ALTER TABLE `productos_seo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `producto_id` (`producto_id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `idx_seo_slug` (`slug`);

--
-- Indices de la tabla `productos_tallas`
--
ALTER TABLE `productos_tallas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_producto_talla` (`producto_id`,`talla_id`),
  ADD KEY `idx_productos_tallas_producto` (`producto_id`),
  ADD KEY `idx_productos_tallas_talla` (`talla_id`);

--
-- Indices de la tabla `programa_lealtad`
--
ALTER TABLE `programa_lealtad`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cliente_id` (`cliente_id`),
  ADD KEY `idx_lealtad_puntos` (`puntos_disponibles`),
  ADD KEY `idx_lealtad_nivel` (`nivel_cliente`),
  ADD KEY `fk_programa_lealtad_creado_por` (`creado_por`),
  ADD KEY `fk_programa_lealtad_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `promociones`
--
ALTER TABLE `promociones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD KEY `creado_por` (`creado_por`),
  ADD KEY `idx_promociones_fechas` (`fecha_inicio`,`fecha_fin`),
  ADD KEY `idx_promociones_activo` (`activo`);

--
-- Indices de la tabla `promociones_categorias`
--
ALTER TABLE `promociones_categorias`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_promocion_categoria` (`promocion_id`,`categoria_id`),
  ADD KEY `categoria_id` (`categoria_id`);

--
-- Indices de la tabla `promociones_productos`
--
ALTER TABLE `promociones_productos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_promocion_producto` (`promocion_id`,`producto_id`),
  ADD KEY `producto_id` (`producto_id`);

--
-- Indices de la tabla `promociones_uso`
--
ALTER TABLE `promociones_uso`
  ADD PRIMARY KEY (`id`),
  ADD KEY `venta_id` (`venta_id`),
  ADD KEY `idx_uso_promocion` (`promocion_id`),
  ADD KEY `idx_uso_cliente` (`cliente_id`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo_proveedor` (`codigo_proveedor`),
  ADD KEY `distrito_id` (`distrito_id`),
  ADD KEY `creado_por` (`creado_por`),
  ADD KEY `idx_proveedores_activo` (`activo`),
  ADD KEY `idx_proveedores_documento` (`tipo_documento`,`numero_documento`),
  ADD KEY `fk_proveedores_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `provincias`
--
ALTER TABLE `provincias`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_provincias_departamento` (`departamento_id`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`);

--
-- Indices de la tabla `roles_permisos`
--
ALTER TABLE `roles_permisos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_rol_permiso` (`rol_id`,`permiso_id`),
  ADD KEY `permiso_id` (`permiso_id`);

--
-- Indices de la tabla `sesiones_usuario`
--
ALTER TABLE `sesiones_usuario`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token_sesion` (`token_sesion`),
  ADD KEY `idx_sesiones_usuario` (`usuario_id`),
  ADD KEY `idx_sesiones_token` (`token_sesion`);

--
-- Indices de la tabla `tallas`
--
ALTER TABLE `tallas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD KEY `idx_tallas_categoria` (`categoria_talla`),
  ADD KEY `idx_tallas_activo` (`activo`),
  ADD KEY `fk_tallas_creado_por` (`creado_por`),
  ADD KEY `fk_tallas_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `tareas_seguimiento`
--
ALTER TABLE `tareas_seguimiento`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cliente_id` (`cliente_id`),
  ADD KEY `interaccion_id` (`interaccion_id`),
  ADD KEY `creado_por` (`creado_por`),
  ADD KEY `idx_tareas_asignado` (`asignado_a`),
  ADD KEY `idx_tareas_fecha` (`fecha_programada`),
  ADD KEY `idx_tareas_estado` (`estado`);

--
-- Indices de la tabla `tipos_gasto`
--
ALTER TABLE `tipos_gasto`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`);

--
-- Indices de la tabla `transacciones_puntos`
--
ALTER TABLE `transacciones_puntos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `venta_id` (`venta_id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `idx_transacciones_cliente` (`cliente_id`),
  ADD KEY `idx_transacciones_fecha` (`fecha_transaccion`),
  ADD KEY `idx_transacciones_tipo` (`tipo_transaccion`);

--
-- Indices de la tabla `transferencias_inventario`
--
ALTER TABLE `transferencias_inventario`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `numero_transferencia` (`numero_transferencia`),
  ADD KEY `autorizado_por` (`autorizado_por`),
  ADD KEY `recibido_por` (`recibido_por`),
  ADD KEY `idx_transferencias_fecha` (`fecha_transferencia`),
  ADD KEY `idx_transferencias_estado` (`estado`);

--
-- Indices de la tabla `unidades_medida`
--
ALTER TABLE `unidades_medida`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD KEY `fk_unidades_medida_creado_por` (`creado_por`),
  ADD KEY `fk_unidades_medida_modificado_por` (`modificado_por`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `codigo_empleado` (`codigo_empleado`),
  ADD KEY `idx_usuarios_rol` (`rol_id`),
  ADD KEY `idx_usuarios_activo` (`activo`),
  ADD KEY `idx_usuarios_email` (`email`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `numero_venta` (`numero_venta`),
  ADD KEY `canal_venta_id` (`canal_venta_id`),
  ADD KEY `cajero_id` (`cajero_id`),
  ADD KEY `creado_por` (`creado_por`),
  ADD KEY `modificado_por` (`modificado_por`),
  ADD KEY `idx_ventas_cliente` (`cliente_id`),
  ADD KEY `idx_ventas_fecha` (`fecha`),
  ADD KEY `idx_ventas_estado` (`estado`),
  ADD KEY `idx_ventas_vendedor` (`vendedor_id`),
  ADD KEY `idx_ventas_total` (`total`);

--
-- Indices de la tabla `ventas_descuentos`
--
ALTER TABLE `ventas_descuentos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `aplicado_por` (`aplicado_por`),
  ADD KEY `idx_descuentos_venta` (`venta_id`);

--
-- Indices de la tabla `ventas_entrega`
--
ALTER TABLE `ventas_entrega`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `venta_id` (`venta_id`),
  ADD KEY `distrito_entrega_id` (`distrito_entrega_id`),
  ADD KEY `idx_entrega_estado` (`estado_entrega`),
  ADD KEY `idx_entrega_fecha` (`fecha_programada`);

--
-- Indices de la tabla `ventas_facturacion`
--
ALTER TABLE `ventas_facturacion`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `venta_id` (`venta_id`),
  ADD KEY `idx_facturacion_comprobante` (`tipo_comprobante`,`serie_comprobante`,`numero_comprobante`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `arqueos_caja`
--
ALTER TABLE `arqueos_caja`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auditoria_logs`
--
ALTER TABLE `auditoria_logs`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cajas`
--
ALTER TABLE `cajas`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `canales_venta`
--
ALTER TABLE `canales_venta`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `clientes_comercial`
--
ALTER TABLE `clientes_comercial`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `clientes_contacto`
--
ALTER TABLE `clientes_contacto`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `clientes_direcciones`
--
ALTER TABLE `clientes_direcciones`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `clientes_preferencias`
--
ALTER TABLE `clientes_preferencias`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `colores`
--
ALTER TABLE `colores`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `compras`
--
ALTER TABLE `compras`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `configuracion_impuestos`
--
ALTER TABLE `configuracion_impuestos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `configuracion_tienda`
--
ALTER TABLE `configuracion_tienda`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `cotizaciones`
--
ALTER TABLE `cotizaciones`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `departamentos`
--
ALTER TABLE `departamentos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_cotizacion`
--
ALTER TABLE `detalle_cotizacion`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_devolucion`
--
ALTER TABLE `detalle_devolucion`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_transferencia`
--
ALTER TABLE `detalle_transferencia`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `devoluciones`
--
ALTER TABLE `devoluciones`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `distritos`
--
ALTER TABLE `distritos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `gastos`
--
ALTER TABLE `gastos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `horarios_atencion`
--
ALTER TABLE `horarios_atencion`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `interacciones_cliente`
--
ALTER TABLE `interacciones_cliente`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `marcas`
--
ALTER TABLE `marcas`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `metodos_pago_venta`
--
ALTER TABLE `metodos_pago_venta`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `movimientos_caja`
--
ALTER TABLE `movimientos_caja`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `movimientos_inventario`
--
ALTER TABLE `movimientos_inventario`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `paises`
--
ALTER TABLE `paises`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `permisos`
--
ALTER TABLE `permisos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `productos_colores`
--
ALTER TABLE `productos_colores`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `productos_imagenes`
--
ALTER TABLE `productos_imagenes`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `productos_inventario`
--
ALTER TABLE `productos_inventario`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `productos_precios`
--
ALTER TABLE `productos_precios`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `productos_seo`
--
ALTER TABLE `productos_seo`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `productos_tallas`
--
ALTER TABLE `productos_tallas`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `programa_lealtad`
--
ALTER TABLE `programa_lealtad`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `promociones`
--
ALTER TABLE `promociones`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `promociones_categorias`
--
ALTER TABLE `promociones_categorias`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `promociones_productos`
--
ALTER TABLE `promociones_productos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `promociones_uso`
--
ALTER TABLE `promociones_uso`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `provincias`
--
ALTER TABLE `provincias`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `roles_permisos`
--
ALTER TABLE `roles_permisos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT de la tabla `sesiones_usuario`
--
ALTER TABLE `sesiones_usuario`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tallas`
--
ALTER TABLE `tallas`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT de la tabla `tareas_seguimiento`
--
ALTER TABLE `tareas_seguimiento`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tipos_gasto`
--
ALTER TABLE `tipos_gasto`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `transacciones_puntos`
--
ALTER TABLE `transacciones_puntos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `transferencias_inventario`
--
ALTER TABLE `transferencias_inventario`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `unidades_medida`
--
ALTER TABLE `unidades_medida`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `ventas_descuentos`
--
ALTER TABLE `ventas_descuentos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `ventas_entrega`
--
ALTER TABLE `ventas_entrega`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `ventas_facturacion`
--
ALTER TABLE `ventas_facturacion`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `arqueos_caja`
--
ALTER TABLE `arqueos_caja`
  ADD CONSTRAINT `arqueos_caja_ibfk_1` FOREIGN KEY (`caja_id`) REFERENCES `cajas` (`id`),
  ADD CONSTRAINT `arqueos_caja_ibfk_2` FOREIGN KEY (`usuario_apertura`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `arqueos_caja_ibfk_3` FOREIGN KEY (`usuario_cierre`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `auditoria_logs`
--
ALTER TABLE `auditoria_logs`
  ADD CONSTRAINT `auditoria_logs_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_auditoria_logs_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `cajas`
--
ALTER TABLE `cajas`
  ADD CONSTRAINT `cajas_ibfk_1` FOREIGN KEY (`responsable_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_cajas_creado_por` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_cajas_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `canales_venta`
--
ALTER TABLE `canales_venta`
  ADD CONSTRAINT `fk_canales_venta_creado_por` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_canales_venta_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD CONSTRAINT `categorias_ibfk_1` FOREIGN KEY (`categoria_padre_id`) REFERENCES `categorias` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `categorias_ibfk_2` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `categorias_ibfk_3` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD CONSTRAINT `clientes_ibfk_1` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `clientes_ibfk_2` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `clientes_comercial`
--
ALTER TABLE `clientes_comercial`
  ADD CONSTRAINT `clientes_comercial_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `clientes_comercial_ibfk_2` FOREIGN KEY (`vendedor_asignado_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `clientes_contacto`
--
ALTER TABLE `clientes_contacto`
  ADD CONSTRAINT `clientes_contacto_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `clientes_direcciones`
--
ALTER TABLE `clientes_direcciones`
  ADD CONSTRAINT `clientes_direcciones_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `clientes_direcciones_ibfk_2` FOREIGN KEY (`distrito_id`) REFERENCES `distritos` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `clientes_preferencias`
--
ALTER TABLE `clientes_preferencias`
  ADD CONSTRAINT `clientes_preferencias_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `clientes_preferencias_ibfk_2` FOREIGN KEY (`canal_preferido_id`) REFERENCES `canales_venta` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `clientes_preferencias_ibfk_3` FOREIGN KEY (`talla_preferida_id`) REFERENCES `tallas` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `clientes_preferencias_ibfk_4` FOREIGN KEY (`color_preferido_id`) REFERENCES `colores` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `clientes_preferencias_ibfk_5` FOREIGN KEY (`marca_preferida_id`) REFERENCES `marcas` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `colores`
--
ALTER TABLE `colores`
  ADD CONSTRAINT `fk_colores_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `compras`
--
ALTER TABLE `compras`
  ADD CONSTRAINT `compras_ibfk_1` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`id`),
  ADD CONSTRAINT `compras_ibfk_2` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_compras_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `configuracion_impuestos`
--
ALTER TABLE `configuracion_impuestos`
  ADD CONSTRAINT `configuracion_impuestos_ibfk_1` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `configuracion_tienda`
--
ALTER TABLE `configuracion_tienda`
  ADD CONSTRAINT `configuracion_tienda_ibfk_1` FOREIGN KEY (`distrito_id`) REFERENCES `distritos` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_configuracion_tienda_creado_por` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_configuracion_tienda_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `cotizaciones`
--
ALTER TABLE `cotizaciones`
  ADD CONSTRAINT `cotizaciones_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`),
  ADD CONSTRAINT `cotizaciones_ibfk_2` FOREIGN KEY (`vendedor_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `cotizaciones_ibfk_3` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `cotizaciones_ibfk_4` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_cotizaciones_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `departamentos`
--
ALTER TABLE `departamentos`
  ADD CONSTRAINT `departamentos_ibfk_1` FOREIGN KEY (`pais_id`) REFERENCES `paises` (`id`);

--
-- Filtros para la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  ADD CONSTRAINT `detalle_compra_ibfk_1` FOREIGN KEY (`compra_id`) REFERENCES `compras` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `detalle_compra_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`),
  ADD CONSTRAINT `fk_detalle_compra_creado_por` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_detalle_compra_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `detalle_cotizacion`
--
ALTER TABLE `detalle_cotizacion`
  ADD CONSTRAINT `detalle_cotizacion_ibfk_1` FOREIGN KEY (`cotizacion_id`) REFERENCES `cotizaciones` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `detalle_cotizacion_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`),
  ADD CONSTRAINT `detalle_cotizacion_ibfk_3` FOREIGN KEY (`talla_id`) REFERENCES `tallas` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `detalle_cotizacion_ibfk_4` FOREIGN KEY (`color_id`) REFERENCES `colores` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_detalle_cotizacion_creado_por` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_detalle_cotizacion_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `detalle_devolucion`
--
ALTER TABLE `detalle_devolucion`
  ADD CONSTRAINT `detalle_devolucion_ibfk_1` FOREIGN KEY (`devolucion_id`) REFERENCES `devoluciones` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `detalle_devolucion_ibfk_2` FOREIGN KEY (`detalle_venta_id`) REFERENCES `detalle_venta` (`id`),
  ADD CONSTRAINT `fk_detalle_devolucion_creado_por` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_detalle_devolucion_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `detalle_transferencia`
--
ALTER TABLE `detalle_transferencia`
  ADD CONSTRAINT `detalle_transferencia_ibfk_1` FOREIGN KEY (`transferencia_id`) REFERENCES `transferencias_inventario` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `detalle_transferencia_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`),
  ADD CONSTRAINT `fk_detalle_transferencia_creado_por` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_detalle_transferencia_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD CONSTRAINT `detalle_venta_ibfk_1` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `detalle_venta_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`),
  ADD CONSTRAINT `detalle_venta_ibfk_3` FOREIGN KEY (`talla_id`) REFERENCES `tallas` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `detalle_venta_ibfk_4` FOREIGN KEY (`color_id`) REFERENCES `colores` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_detalle_venta_creado_por` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_detalle_venta_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `devoluciones`
--
ALTER TABLE `devoluciones`
  ADD CONSTRAINT `devoluciones_ibfk_1` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`),
  ADD CONSTRAINT `devoluciones_ibfk_2` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`),
  ADD CONSTRAINT `devoluciones_ibfk_3` FOREIGN KEY (`autorizado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `devoluciones_ibfk_4` FOREIGN KEY (`procesado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `distritos`
--
ALTER TABLE `distritos`
  ADD CONSTRAINT `distritos_ibfk_1` FOREIGN KEY (`provincia_id`) REFERENCES `provincias` (`id`);

--
-- Filtros para la tabla `gastos`
--
ALTER TABLE `gastos`
  ADD CONSTRAINT `gastos_ibfk_1` FOREIGN KEY (`tipo_gasto_id`) REFERENCES `tipos_gasto` (`id`),
  ADD CONSTRAINT `gastos_ibfk_2` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `gastos_ibfk_3` FOREIGN KEY (`autorizado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `gastos_ibfk_4` FOREIGN KEY (`pagado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `gastos_ibfk_5` FOREIGN KEY (`caja_id`) REFERENCES `cajas` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `gastos_ibfk_6` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `interacciones_cliente`
--
ALTER TABLE `interacciones_cliente`
  ADD CONSTRAINT `interacciones_cliente_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `interacciones_cliente_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `marcas`
--
ALTER TABLE `marcas`
  ADD CONSTRAINT `fk_marcas_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `metodos_pago_venta`
--
ALTER TABLE `metodos_pago_venta`
  ADD CONSTRAINT `metodos_pago_venta_ibfk_1` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `movimientos_caja`
--
ALTER TABLE `movimientos_caja`
  ADD CONSTRAINT `movimientos_caja_ibfk_1` FOREIGN KEY (`caja_id`) REFERENCES `cajas` (`id`),
  ADD CONSTRAINT `movimientos_caja_ibfk_2` FOREIGN KEY (`arqueo_id`) REFERENCES `arqueos_caja` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `movimientos_caja_ibfk_3` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `movimientos_caja_ibfk_4` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `movimientos_inventario`
--
ALTER TABLE `movimientos_inventario`
  ADD CONSTRAINT `movimientos_inventario_ibfk_1` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `movimientos_inventario_ibfk_2` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `movimientos_inventario_ibfk_3` FOREIGN KEY (`compra_id`) REFERENCES `compras` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `movimientos_inventario_ibfk_4` FOREIGN KEY (`devolucion_id`) REFERENCES `devoluciones` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `movimientos_inventario_ibfk_5` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD CONSTRAINT `password_reset_tokens_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`),
  ADD CONSTRAINT `productos_ibfk_2` FOREIGN KEY (`marca_id`) REFERENCES `marcas` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `productos_ibfk_3` FOREIGN KEY (`unidad_medida_id`) REFERENCES `unidades_medida` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `productos_ibfk_4` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `productos_ibfk_5` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `productos_colores`
--
ALTER TABLE `productos_colores`
  ADD CONSTRAINT `productos_colores_ibfk_1` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `productos_colores_ibfk_2` FOREIGN KEY (`color_id`) REFERENCES `colores` (`id`);

--
-- Filtros para la tabla `productos_imagenes`
--
ALTER TABLE `productos_imagenes`
  ADD CONSTRAINT `productos_imagenes_ibfk_1` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `productos_imagenes_ibfk_2` FOREIGN KEY (`color_id`) REFERENCES `colores` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `productos_inventario`
--
ALTER TABLE `productos_inventario`
  ADD CONSTRAINT `productos_inventario_ibfk_1` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `productos_precios`
--
ALTER TABLE `productos_precios`
  ADD CONSTRAINT `productos_precios_ibfk_1` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `productos_precios_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `productos_seo`
--
ALTER TABLE `productos_seo`
  ADD CONSTRAINT `productos_seo_ibfk_1` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `productos_tallas`
--
ALTER TABLE `productos_tallas`
  ADD CONSTRAINT `productos_tallas_ibfk_1` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `productos_tallas_ibfk_2` FOREIGN KEY (`talla_id`) REFERENCES `tallas` (`id`);

--
-- Filtros para la tabla `programa_lealtad`
--
ALTER TABLE `programa_lealtad`
  ADD CONSTRAINT `fk_programa_lealtad_creado_por` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_programa_lealtad_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `programa_lealtad_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `promociones`
--
ALTER TABLE `promociones`
  ADD CONSTRAINT `promociones_ibfk_1` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `promociones_categorias`
--
ALTER TABLE `promociones_categorias`
  ADD CONSTRAINT `promociones_categorias_ibfk_1` FOREIGN KEY (`promocion_id`) REFERENCES `promociones` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `promociones_categorias_ibfk_2` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `promociones_productos`
--
ALTER TABLE `promociones_productos`
  ADD CONSTRAINT `promociones_productos_ibfk_1` FOREIGN KEY (`promocion_id`) REFERENCES `promociones` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `promociones_productos_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `promociones_uso`
--
ALTER TABLE `promociones_uso`
  ADD CONSTRAINT `promociones_uso_ibfk_1` FOREIGN KEY (`promocion_id`) REFERENCES `promociones` (`id`),
  ADD CONSTRAINT `promociones_uso_ibfk_2` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`),
  ADD CONSTRAINT `promociones_uso_ibfk_3` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`);

--
-- Filtros para la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD CONSTRAINT `fk_proveedores_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `proveedores_ibfk_1` FOREIGN KEY (`distrito_id`) REFERENCES `distritos` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `proveedores_ibfk_2` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `provincias`
--
ALTER TABLE `provincias`
  ADD CONSTRAINT `provincias_ibfk_1` FOREIGN KEY (`departamento_id`) REFERENCES `departamentos` (`id`);

--
-- Filtros para la tabla `roles_permisos`
--
ALTER TABLE `roles_permisos`
  ADD CONSTRAINT `roles_permisos_ibfk_1` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `roles_permisos_ibfk_2` FOREIGN KEY (`permiso_id`) REFERENCES `permisos` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `sesiones_usuario`
--
ALTER TABLE `sesiones_usuario`
  ADD CONSTRAINT `sesiones_usuario_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `tallas`
--
ALTER TABLE `tallas`
  ADD CONSTRAINT `fk_tallas_creado_por` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tallas_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `tareas_seguimiento`
--
ALTER TABLE `tareas_seguimiento`
  ADD CONSTRAINT `tareas_seguimiento_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tareas_seguimiento_ibfk_2` FOREIGN KEY (`interaccion_id`) REFERENCES `interacciones_cliente` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `tareas_seguimiento_ibfk_3` FOREIGN KEY (`asignado_a`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `tareas_seguimiento_ibfk_4` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `transacciones_puntos`
--
ALTER TABLE `transacciones_puntos`
  ADD CONSTRAINT `transacciones_puntos_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `transacciones_puntos_ibfk_2` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `transacciones_puntos_ibfk_3` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `transferencias_inventario`
--
ALTER TABLE `transferencias_inventario`
  ADD CONSTRAINT `transferencias_inventario_ibfk_1` FOREIGN KEY (`autorizado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `transferencias_inventario_ibfk_2` FOREIGN KEY (`recibido_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `unidades_medida`
--
ALTER TABLE `unidades_medida`
  ADD CONSTRAINT `fk_unidades_medida_creado_por` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_unidades_medida_modificado_por` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`);

--
-- Filtros para la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `ventas_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`),
  ADD CONSTRAINT `ventas_ibfk_2` FOREIGN KEY (`canal_venta_id`) REFERENCES `canales_venta` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `ventas_ibfk_3` FOREIGN KEY (`vendedor_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `ventas_ibfk_4` FOREIGN KEY (`cajero_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `ventas_ibfk_5` FOREIGN KEY (`creado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `ventas_ibfk_6` FOREIGN KEY (`modificado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `ventas_descuentos`
--
ALTER TABLE `ventas_descuentos`
  ADD CONSTRAINT `ventas_descuentos_ibfk_1` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ventas_descuentos_ibfk_2` FOREIGN KEY (`aplicado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `ventas_entrega`
--
ALTER TABLE `ventas_entrega`
  ADD CONSTRAINT `ventas_entrega_ibfk_1` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ventas_entrega_ibfk_2` FOREIGN KEY (`distrito_entrega_id`) REFERENCES `distritos` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `ventas_facturacion`
--
ALTER TABLE `ventas_facturacion`
  ADD CONSTRAINT `ventas_facturacion_ibfk_1` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
