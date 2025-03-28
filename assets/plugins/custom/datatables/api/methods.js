var DefaultDatatableDemo = function () {
    var t =
        function () {
            var t = {
                data: {
                    type: "remote",
                    source: { read: { url: "http://keenthemes.com/metronic/preview/inc/api/datatables/demos/default.php" } }, pageSize: 20, saveState: { cookie: !0, webstorage: !0 }, serverPaging: !0, serverFiltering: !0, serverSorting: !0
                },
                layout: { theme: "default", class: "", scroll: !0, height: 550, footer: !1 }, sortable: !0, filterable: !1, pagination: !0,
                columns: [{ field: "RecordID", title: "#", sortable: !1, width: 40, selector: { class: "m-checkbox--solid m-checkbox--brand" } }, { field: "OrderID", title: "Order ID", filterable: !1, width: 150, template: "{{OrderID}} - {{ShipCountry}}" }, { field: "ShipCountry", title: "Ship Country", width: 150, template: function (t) { return t.ShipCountry + " - " + t.ShipCity } }, { field: "ShipCity", title: "Ship City", sortable: !1 }, { field: "Currency", title: "Currency", width: 100 }, { field: "ShipDate", title: "Ship Date", sortable: "asc" }, { field: "Latitude", title: "Latitude" }, { field: "Status", title: "Status", template: function (t) { var e = { 1: { title: "Pending", class: "m-badge--brand" }, 2: { title: "Delivered", class: " m-badge--metal" }, 3: { title: "Canceled", class: " m-badge--primary" }, 4: { title: "Success", class: " m-badge--success" }, 5: { title: "Info", class: " m-badge--info" }, 6: { title: "Danger", class: " m-badge--danger" }, 7: { title: "Warning", class: " m-badge--warning" } }; return '<span class="m-badge ' + e[t.Status].class + ' m-badge--wide">' + e[t.Status].title + "</span>" } }, { field: "Type", title: "Type", template: function (t) { var e = { 1: { title: "Online", state: "danger" }, 2: { title: "Retail", state: "primary" }, 3: { title: "Direct", state: "accent" } }; return '<span class="m-badge m-badge--' + e[t.Type].state + ' m-badge--dot"></span>&nbsp;<span class="m--font-bold m--font-' + e[t.Type].state + '">' + e[t.Type].title + "</span>" } }, { field: "Actions", width: 110, title: "Actions", sortable: !1, overflow: "visible", template: function (t) { return '\t\t\t\t\t\t<div class="dropdown ' + (t.getDatatable().getPageSize() - t.getIndex() <= 4 ? "dropup" : "") + '">\t\t\t\t\t\t\t<a href="#" class="btn m-btn m-btn--hover-accent m-btn--icon m-btn--icon-only m-btn--pill" data-toggle="dropdown">                                <i class="la la-ellipsis-h"></i>                            </a>\t\t\t\t\t\t  \t<div class="dropdown-menu dropdown-menu-right">\t\t\t\t\t\t    \t<a class="dropdown-item" href="#"><i class="la la-edit"></i> Edit Details</a>\t\t\t\t\t\t    \t<a class="dropdown-item" href="#"><i class="la la-leaf"></i> Update Status</a>\t\t\t\t\t\t    \t<a class="dropdown-item" href="#"><i class="la la-print"></i> Generate Report</a>\t\t\t\t\t\t  \t</div>\t\t\t\t\t\t</div>\t\t\t\t\t\t<a href="#" class="m-portlet__nav-link btn m-btn m-btn--hover-accent m-btn--icon m-btn--icon-only m-btn--pill" title="Edit details">\t\t\t\t\t\t\t<i class="la la-edit"></i>\t\t\t\t\t\t</a>\t\t\t\t\t\t<a href="#" class="m-portlet__nav-link btn m-btn m-btn--hover-danger m-btn--icon m-btn--icon-only m-btn--pill" title="Delete">\t\t\t\t\t\t\t<i class="la la-trash"></i>\t\t\t\t\t\t</a>\t\t\t\t\t' } }]
            },
            e = $(".m_datatable").mDatatable(t),
            a = e.getDataSourceQuery(); $("#m_form_search").on("keyup",

                function (t) {
                    var a = e.getDataSourceQuery();
                    a.generalSearch = $(this).val().toLowerCase(), e.setDataSourceQuery(a), e.load()
                }).val(a.generalSearch),
            $("#m_form_status, #m_form_type").selectpicker(),
            $("#m_datatable_destroy").on("click",
                function () { e.destroy() }), $("#m_datatable_init").on("click",
                function () { e = $(".m_datatable").mDatatable(t) }),
            $("#m_datatable_reload").on("click",
                function () { e.reload() }),
            $("#m_datatable_sort").on("click", function () { e.sort("ShipCity") }),
            $("#m_datatable_get").on("click",
                function () {
                    var t = e.setSelectedRecords().getColumn("ShipCity").getValue();
                    "" === t && (t = "Select checbox"), $("#datatable_value").html(t)
                }), $("#m_datatable_check").on("click",
                function () {
                    var t = $("#m_datatable_check_input").val();
                    e.setActive(t)
                }), $("#m_datatable_check_all").on("click",
                function () { e.setActiveAll(!0) }),
            $("#m_datatable_uncheck_all").on("click", function () { e.setActiveAll(!1) })
        }; return { init: function () { t() } }
}(); jQuery(document).ready(function () { DefaultDatatableDemo.init() });