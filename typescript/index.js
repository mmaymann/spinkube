export async function handleRequest(request) {

    console.log('Handling request ${JSON.stringify(request)}')

    return {
        status: 200,
        headers: { "content-type": "text/plain" },
        body: "Hello from JS-SDK"
    }
}
