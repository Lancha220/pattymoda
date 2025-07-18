package com.pattymoda.controller;

import com.pattymoda.entity.Producto;
import com.pattymoda.service.ProductoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/productos")
@Tag(name = "Productos", description = "API para gestión de productos")
@CrossOrigin(origins = "*")
public class ProductoController extends BaseController<Producto, Long> {

    private final ProductoService productoService;

    public ProductoController(ProductoService productoService) {
        super(productoService);
        this.productoService = productoService;
    }

    @Operation(summary = "Obtener todos los productos")
    @GetMapping
    public ResponseEntity<List<Producto>> getAllProductos() {
        return super.findAll();
    }

    @Operation(summary = "Obtener productos paginados")
    @GetMapping("/page")
    public ResponseEntity<Page<Producto>> getProductosPaginados(Pageable pageable) {
        return super.findAll(pageable);
    }

    @Operation(summary = "Obtener producto por ID")
    @GetMapping("/{id}")
    public ResponseEntity<Producto> getProductoById(@PathVariable Long id) {
        return super.findById(id);
    }

    @Operation(summary = "Buscar producto por código")
    @GetMapping("/codigo/{codigoProducto}")
    public ResponseEntity<Producto> getProductoByCodigo(@PathVariable String codigoProducto) {
        return productoService.findByCodigoProducto(codigoProducto)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @Operation(summary = "Buscar producto por SKU")
    @GetMapping("/sku/{sku}")
    public ResponseEntity<Producto> getProductoBySku(@PathVariable String sku) {
        return productoService.findBySku(sku)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @Operation(summary = "Buscar producto por código de barras")
    @GetMapping("/barras/{codigoBarras}")
    public ResponseEntity<Producto> getProductoByCodigoBarras(@PathVariable String codigoBarras) {
        return productoService.findByCodigoBarras(codigoBarras)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @Operation(summary = "Buscar productos activos")
    @GetMapping("/activos")
    public ResponseEntity<Page<Producto>> getProductosActivos(
            @RequestParam(defaultValue = "true") Boolean activo,
            Pageable pageable) {
        Page<Producto> productos = productoService.findByActivo(activo, pageable);
        return ResponseEntity.ok(productos);
    }

    @Operation(summary = "Buscar productos por categoría")
    @GetMapping("/categoria/{categoriaId}")
    public ResponseEntity<Page<Producto>> getProductosByCategoria(
            @PathVariable Long categoriaId,
            Pageable pageable) {
        Page<Producto> productos = productoService.findByCategoriaId(categoriaId, pageable);
        return ResponseEntity.ok(productos);
    }

    @Operation(summary = "Buscar productos por marca")
    @GetMapping("/marca/{marcaId}")
    public ResponseEntity<Page<Producto>> getProductosByMarca(
            @PathVariable Long marcaId,
            Pageable pageable) {
        Page<Producto> productos = productoService.findByMarcaId(marcaId, pageable);
        return ResponseEntity.ok(productos);
    }

    @Operation(summary = "Buscar productos destacados")
    @GetMapping("/destacados")
    public ResponseEntity<Page<Producto>> getProductosDestacados(
            @RequestParam(defaultValue = "true") Boolean destacado,
            Pageable pageable) {
        Page<Producto> productos = productoService.findByDestacado(destacado, pageable);
        return ResponseEntity.ok(productos);
    }

    @Operation(summary = "Buscar productos nuevos")
    @GetMapping("/nuevos")
    public ResponseEntity<Page<Producto>> getProductosNuevos(
            @RequestParam(defaultValue = "true") Boolean nuevo,
            Pageable pageable) {
        Page<Producto> productos = productoService.findByNuevo(nuevo, pageable);
        return ResponseEntity.ok(productos);
    }

    @Operation(summary = "Buscar productos")
    @GetMapping("/buscar")
    public ResponseEntity<Page<Producto>> buscarProductos(
            @RequestParam String busqueda,
            Pageable pageable) {
        Page<Producto> productos = productoService.buscarProductos(busqueda, pageable);
        return ResponseEntity.ok(productos);
    }

    @Operation(summary = "Obtener productos destacados por categoría")
    @GetMapping("/destacados/categoria/{categoriaId}")
    public ResponseEntity<List<Producto>> getDestacadosByCategoria(@PathVariable Long categoriaId) {
        List<Producto> productos = productoService.findDestacadosByCategoria(categoriaId);
        return ResponseEntity.ok(productos);
    }

    @Operation(summary = "Obtener productos con stock bajo")
    @GetMapping("/stock-bajo")
    public ResponseEntity<List<Producto>> getProductosStockBajo() {
        List<Producto> productos = productoService.findProductosStockBajo();
        return ResponseEntity.ok(productos);
    }

    @Operation(summary = "Crear nuevo producto")
    @PostMapping
    public ResponseEntity<Producto> createProducto(@RequestBody Producto producto) {
        try {
            Producto nuevoProducto = productoService.crearProducto(producto);
            return ResponseEntity.status(201).body(nuevoProducto);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @Operation(summary = "Actualizar producto")
    @PutMapping("/{id}")
    public ResponseEntity<Producto> updateProducto(@PathVariable Long id, @RequestBody Producto producto) {
        try {
            Producto productoActualizado = productoService.actualizarProducto(id, producto);
            return ResponseEntity.ok(productoActualizado);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @Operation(summary = "Cambiar estado de producto")
    @PatchMapping("/{id}/estado")
    public ResponseEntity<Void> cambiarEstado(@PathVariable Long id, @RequestParam Boolean activo) {
        try {
            productoService.cambiarEstado(id, activo);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(summary = "Cambiar destacado de producto")
    @PatchMapping("/{id}/destacado")
    public ResponseEntity<Void> cambiarDestacado(@PathVariable Long id, @RequestParam Boolean destacado) {
        try {
            productoService.cambiarDestacado(id, destacado);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(summary = "Cambiar nuevo de producto")
    @PatchMapping("/{id}/nuevo")
    public ResponseEntity<Void> cambiarNuevo(@PathVariable Long id, @RequestParam Boolean nuevo) {
        try {
            productoService.cambiarNuevo(id, nuevo);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(summary = "Eliminar producto")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProducto(@PathVariable Long id) {
        return super.delete(id);
    }

    @Operation(summary = "Contar productos activos")
    @GetMapping("/count/activos")
    public ResponseEntity<Long> countProductosActivos() {
        long count = productoService.countProductosActivos();
        return ResponseEntity.ok(count);
    }

    @Operation(summary = "Contar productos destacados")
    @GetMapping("/count/destacados")
    public ResponseEntity<Long> countProductosDestacados() {
        long count = productoService.countProductosDestacados();
        return ResponseEntity.ok(count);
    }

    @Operation(summary = "Verificar si existe código de producto")
    @GetMapping("/exists/codigo/{codigoProducto}")
    public ResponseEntity<Boolean> existsByCodigoProducto(@PathVariable String codigoProducto) {
        boolean exists = productoService.existsByCodigoProducto(codigoProducto);
        return ResponseEntity.ok(exists);
    }

    @Operation(summary = "Verificar si existe SKU")
    @GetMapping("/exists/sku/{sku}")
    public ResponseEntity<Boolean> existsBySku(@PathVariable String sku) {
        boolean exists = productoService.existsBySku(sku);
        return ResponseEntity.ok(exists);
    }

    @Operation(summary = "Verificar si existe código de barras")
    @GetMapping("/exists/barras/{codigoBarras}")
    public ResponseEntity<Boolean> existsByCodigoBarras(@PathVariable String codigoBarras) {
        boolean exists = productoService.existsByCodigoBarras(codigoBarras);
        return ResponseEntity.ok(exists);
    }
} 