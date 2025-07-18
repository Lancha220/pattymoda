package com.pattymoda.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "productos")
public class Producto extends BaseEntity {

    @Column(name = "codigo_producto", length = 50, nullable = false, unique = true)
    private String codigoProducto;

    @Column(name = "nombre", length = 255, nullable = false)
    private String nombre;

    @Column(name = "sku", length = 100, nullable = false, unique = true)
    private String sku;

    @Column(name = "codigo_barras", length = 50, unique = true)
    private String codigoBarras;

    @Column(name = "descripcion", columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "descripcion_corta", length = 500)
    private String descripcionCorta;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "categoria_id", nullable = false)
    private Categoria categoria;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "marca_id")
    private Marca marca;

    @Column(name = "modelo", length = 100)
    private String modelo;

    @Column(name = "peso", precision = 8, scale = 3)
    private BigDecimal peso;

    @Column(name = "dimensiones", length = 100)
    private String dimensiones;

    @Column(name = "imagen_principal", length = 255)
    private String imagenPrincipal;

    @Column(name = "requiere_talla")
    private Boolean requiereTalla = true;

    @Column(name = "requiere_color")
    private Boolean requiereColor = true;

    @Column(name = "es_perecedero")
    private Boolean esPerecedero = false;

    @Column(name = "tiempo_entrega_dias")
    private Integer tiempoEntregaDias = 1;

    @Column(name = "garantia_meses")
    private Integer garantiaMeses = 0;

    @Column(name = "destacado")
    private Boolean destacado = false;

    @Column(name = "nuevo")
    private Boolean nuevo = true;

    @Column(name = "activo")
    private Boolean activo = true;

    // Getters and Setters
    public String getCodigoProducto() {
        return codigoProducto;
    }

    public void setCodigoProducto(String codigoProducto) {
        this.codigoProducto = codigoProducto;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getCodigoBarras() {
        return codigoBarras;
    }

    public void setCodigoBarras(String codigoBarras) {
        this.codigoBarras = codigoBarras;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getDescripcionCorta() {
        return descripcionCorta;
    }

    public void setDescripcionCorta(String descripcionCorta) {
        this.descripcionCorta = descripcionCorta;
    }

    public Categoria getCategoria() {
        return categoria;
    }

    public void setCategoria(Categoria categoria) {
        this.categoria = categoria;
    }

    public Marca getMarca() {
        return marca;
    }

    public void setMarca(Marca marca) {
        this.marca = marca;
    }

    public String getModelo() {
        return modelo;
    }

    public void setModelo(String modelo) {
        this.modelo = modelo;
    }

    public BigDecimal getPeso() {
        return peso;
    }

    public void setPeso(BigDecimal peso) {
        this.peso = peso;
    }

    public String getDimensiones() {
        return dimensiones;
    }

    public void setDimensiones(String dimensiones) {
        this.dimensiones = dimensiones;
    }

    public String getImagenPrincipal() {
        return imagenPrincipal;
    }

    public void setImagenPrincipal(String imagenPrincipal) {
        this.imagenPrincipal = imagenPrincipal;
    }

    public Boolean getRequiereTalla() {
        return requiereTalla;
    }

    public void setRequiereTalla(Boolean requiereTalla) {
        this.requiereTalla = requiereTalla;
    }

    public Boolean getRequiereColor() {
        return requiereColor;
    }

    public void setRequiereColor(Boolean requiereColor) {
        this.requiereColor = requiereColor;
    }

    public Boolean getEsPerecedero() {
        return esPerecedero;
    }

    public void setEsPerecedero(Boolean esPerecedero) {
        this.esPerecedero = esPerecedero;
    }

    public Integer getTiempoEntregaDias() {
        return tiempoEntregaDias;
    }

    public void setTiempoEntregaDias(Integer tiempoEntregaDias) {
        this.tiempoEntregaDias = tiempoEntregaDias;
    }

    public Integer getGarantiaMeses() {
        return garantiaMeses;
    }

    public void setGarantiaMeses(Integer garantiaMeses) {
        this.garantiaMeses = garantiaMeses;
    }

    public Boolean getDestacado() {
        return destacado;
    }

    public void setDestacado(Boolean destacado) {
        this.destacado = destacado;
    }

    public Boolean getNuevo() {
        return nuevo;
    }

    public void setNuevo(Boolean nuevo) {
        this.nuevo = nuevo;
    }

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }
} 