import { createLazyFileRoute } from '@tanstack/react-router'
import { Container, Title, Text, Button, Stack } from '@mantine/core'

export const Route = createLazyFileRoute('/')({
  component: Index,
})

function Index() {
  return (
    <Container size="md" py="xl">
      <Stack gap="lg" align="center">
        <Title order={1} size="h1" ta="center">
          Welcome to TimeTracker
        </Title>
        <Text size="lg" ta="center" c="dimmed">
          Professional time tracking made simple and efficient
        </Text>
        <Button size="lg" variant="filled">
          Get Started
        </Button>
      </Stack>
    </Container>
  )
}