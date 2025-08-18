function createTable() {
    fetch('/createTable')
        .then(res => res.text())
        .then(data => displayResult(data))
        .catch(displayError);
}

function addItem() {
    const name = prompt('Enter the item name:');
    if (!name) return;
    fetch('/addItem', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name })
    })
        .then(res => res.text())
        .then(data => displayResult(data))
        .catch(displayError);
}

function getItems() {
    fetch('/getItems')
        .then(res => res.json())
        .then(data => {
            if (!data.length) return displayResult('No items found.');
            let table = `<table>
                            <tr><th>ID</th><th>Name</th></tr>`;
            data.forEach(item => {
                table += `<tr><td>${item.id}</td><td>${item.name}</td></tr>`;
            });
            table += `</table>`;
            document.getElementById('result').innerHTML = table;
        })
        .catch(displayError);
}

function updateItem() {
    const id = prompt('Enter item ID to update:');
    const name = prompt('Enter the new name:');
    if (!id || !name) return;
    fetch(`/updateItem/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name })
    })
        .then(res => res.text())
        .then(data => displayResult(data))
        .catch(displayError);
}

function deleteItem() {
    const id = prompt('Enter item ID to delete:');
    if (!id) return;
    fetch(`/deleteItem/${id}`, { method: 'DELETE' })
        .then(res => res.text())
        .then(data => displayResult(data))
        .catch(displayError);
}

function displayResult(msg) {
    document.getElementById('result').innerHTML = `<p>${msg}</p>`;
}

function displayError(err) {
    document.getElementById('result').innerHTML = `<p style="color:red;">⚠️ Error: ${err}</p>`;
}

