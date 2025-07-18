package com.pattymoda.service;

import com.pattymoda.entity.Producto;
import com.pattymoda.repository.ProductoRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class ProductoService extends BaseService<Producto, Long> {

    private final ProductoRepository productoRepository;

    public ProductoService(ProductoRepository productoRepository) {
        super(productoRepository);
        this.productoRepository = productoRepository;
    }

    public Optional<Producto> findByCodigoProducto(String codigoProducto) {
        return productoRepository.findByCodigoProducto(codigoProducto);
    }

    public Optional<Producto> findBySku(String sku) {
        return productoRepository.findBySku(sku);
    }

    public Optional<Producto> findByCodigoBarras(String codigoBarras) {
        return productoRepository.findByCodigoBarras(codigoBarras);
    }

    public boolean existsByCodigoProducto(String codigoProducto) {
        return productoRepository.existsByCodigoProducto(codigoProducto);
    }

    public boolean existsBySku(String sku) {
        return productoRepository.existsBySku(sku);
    }

    public boolean existsByCodigoBarras(String codigoBarras) {
        return productoRepository.existsByCodigoBarras(codigoBarras);
    }

    public Page<Producto> findByActivo(Boolean activo, Pageable pageable) {
        return productoRepository.findByActivo(activo, pageable);
    }

    public Page<Producto> findByCategoriaId(Long categoriaId, Pageable pageable) {
        return productoRepository.findByCategoriaId(categoriaId, pageable);
    }

    public Page<Producto> findByMarcaId(Long marcaId, Pageable pageable) {
        return productoRepository.findByMarcaId(marcaId, pageable);
    }

    public Page<Producto> findByDestacado(Boolean destacado, Pageable pageable) {
        return productoRepository.findByDestacado(destacado, pageable);
    }

    public Page<Producto> findByNuevo(Boolean nuevo, Pageable pageable) {
        return productoRepository.findByNuevo(nuevo, pageable);
    }

    public Page<Producto> buscarProductos(String busqueda, Pageable pageable) {
        return productoRepository.buscarProductos(busqueda, pageable);
    }

    public List<Producto> findDestacadosByCategoria(Long categoriaId) {
        return productoRepository.findDestacadosByCategoria(categoriaId);
    }

    public List<Producto> findProductosStockBajo() {
        return productoRepository.findProductosStockBajo();
    }

    public long countProductosActivos() {
        return productoRepository.countProductosActivos();
    }

    public long countProductosDestacados() {
        return productoRepository.countProductosDestacados();
    }

    public Producto crearProducto(Producto producto) {
        // Validar que el código de producto no exista
        if (producto.getCodigoProducto() != null && existsByCodigoProducto(producto.getCodigoProducto())) {
            throw new RuntimeException("El código de producto ya está registrado");
        }

        // Validar que el SKU no exista
        if (producto.getSku() != null && existsBySku(producto.getSku())) {
            throw new RuntimeException("El SKU ya está registrado");
        }

        // Validar que el código de barras no exista
        if (producto.getCodigoBarras() != null && existsByCodigoBarras(producto.getCodigoBarras())) {
            throw new RuntimeException("El código de barras ya está registrado");
        }

        return save(producto);
    }

    public Producto actualizarProducto(Long id, Producto productoActualizado) {
        Producto productoExistente = findById(id)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado"));

        // Validar que el código de producto no esté en uso por otro producto
        if (!productoExistente.getCodigoProducto().equals(productoActualizado.getCodigoProducto()) &&
                existsByCodigoProducto(productoActualizado.getCodigoProducto())) {
            throw new RuntimeException("El código de producto ya está registrado");
        }

        // Validar que el SKU no esté en uso por otro producto
        if (!productoExistente.getSku().equals(productoActualizado.getSku()) &&
                existsBySku(productoActualizado.getSku())) {
            throw new RuntimeException("El SKU ya está registrado");
        }

        // Actualizar campos
        productoExistente.setNombre(productoActualizado.getNombre());
        productoExistente.setDescripcion(productoActualizado.getDescripcion());
        productoExistente.setDescripcionCorta(productoActualizado.getDescripcionCorta());
        productoExistente.setCategoria(productoActualizado.getCategoria());
        productoExistente.setMarca(productoActualizado.getMarca());
        productoExistente.setModelo(productoActualizado.getModelo());
        productoExistente.setPeso(productoActualizado.getPeso());
        productoExistente.setDimensiones(productoActualizado.getDimensiones());
        productoExistente.setImagenPrincipal(productoActualizado.getImagenPrincipal());
        productoExistente.setRequiereTalla(productoActualizado.getRequiereTalla());
        productoExistente.setRequiereColor(productoActualizado.getRequiereColor());
        productoExistente.setEsPerecedero(productoActualizado.getEsPerecedero());
        productoExistente.setTiempoEntregaDias(productoActualizado.getTiempoEntregaDias());
        productoExistente.setGarantiaMeses(productoActualizado.getGarantiaMeses());
        productoExistente.setDestacado(productoActualizado.getDestacado());
        productoExistente.setNuevo(productoActualizado.getNuevo());
        productoExistente.setActivo(productoActualizado.getActivo());

        return save(productoExistente);
    }

    public void cambiarEstado(Long id, Boolean activo) {
        Producto producto = findById(id)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado"));
        producto.setActivo(activo);
        save(producto);
    }

    public void cambiarDestacado(Long id, Boolean destacado) {
        Producto producto = findById(id)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado"));
        producto.setDestacado(destacado);
        save(producto);
    }

    public void cambiarNuevo(Long id, Boolean nuevo) {
        Producto producto = findById(id)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado"));
        producto.setNuevo(nuevo);
        save(producto);
    }
} 